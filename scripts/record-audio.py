#!/usr/bin/env python3
"""Toggle output-monitor recording, then copy the saved audio file."""

import fcntl
import html
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time
from datetime import datetime

UNIT = "hypr-system-audio-recording.service"


def run(*args: str, **kwargs) -> str:
    return subprocess.run(
        args, check=True, text=True, stdout=subprocess.PIPE,
        stderr=subprocess.PIPE, timeout=30, **kwargs,
    ).stdout.strip()


def notify(title: str, body: str, *, error: bool = False) -> None:
    subprocess.run(
        ["notify-send", "--app-name=Audio recorder", "--hint=boolean:suppress-sound:true",
         "--urgency=" + ("critical" if error else "normal"), title, html.escape(body)],
        check=False, timeout=5,
    )


def active() -> bool:
    result = subprocess.run(
        ["systemctl", "--user", "is-active", "--quiet", UNIT],
        timeout=5, check=False,
    )
    return result.returncode == 0


def stop_recording(state: Path) -> None:
    filename = Path(state.read_text().strip())
    if active():
        # SIGINT lets FFmpeg flush audio and finalize the MP3 before copying it.
        run("systemctl", "--user", "stop", UNIT)
    try:
        metadata = json.loads(run(
            "ffprobe", "-v", "error", "-show_entries",
            "stream=codec_type:format=duration", "-of", "json", str(filename),
        ))
        if (not metadata.get("streams")
                or any(stream["codec_type"] != "audio" for stream in metadata["streams"])
                or float(metadata.get("format", {}).get("duration", 0)) <= 0):
            raise ValueError("No playable audio was recorded")
    except (subprocess.CalledProcessError, ValueError) as error:
        state.unlink(missing_ok=True)
        raise RuntimeError(
            f"No playable recording at {filename}. Check journalctl --user -u {UNIT}"
        ) from error

    state.unlink(missing_ok=True)
    try:
        # wl-copy's clipboard-serving child must not inherit captured output pipes.
        subprocess.run(
            ["wl-copy", "--type", "text/uri-list"], input=filename.as_uri() + "\r\n",
            text=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
            check=True, timeout=5,
        )
    except (subprocess.SubprocessError, OSError) as error:
        notify("Audio saved; clipboard unavailable", str(filename), error=True)
        print(f"Clipboard failed: {error}", file=sys.stderr)
        return
    notify("Audio saved and copied", str(filename))


def start_recording(state: Path) -> None:
    sink_name = run("pactl", "get-default-sink")
    sinks = json.loads(run("pactl", "--format=json", "list", "sinks"))
    sink = next((item for item in sinks if item["name"] == sink_name), None)
    if not sink or not sink.get("monitor_source"):
        raise RuntimeError("The current audio output has no monitor source")

    music = ""
    if shutil.which("xdg-user-dir"):
        music = run("xdg-user-dir", "MUSIC")
    directory = (Path(music) if music else Path.home() / "Music") / "Recordings"
    directory.mkdir(parents=True, exist_ok=True)
    filename = directory / (datetime.now().strftime("%Y-%m-%d_%H-%M-%S-%f") + ".mp3")
    # A transient user service owns FFmpeg: no stale PID or terminal lifetime issues.
    run(
        "systemd-run", "--user", "--quiet", "--collect", "--service-type=exec",
        "--unit=" + UNIT, "--property=KillSignal=SIGINT",
        "--property=TimeoutStopSec=15s", "--property=SuccessExitStatus=255",
        "--property=UMask=0077",
        "--setenv=XDG_RUNTIME_DIR=" + os.environ["XDG_RUNTIME_DIR"],
        *(["--setenv=PULSE_SERVER=" + os.environ["PULSE_SERVER"]]
          if "PULSE_SERVER" in os.environ else []),
        shutil.which("ffmpeg"), "-hide_banner", "-loglevel", "error", "-nostdin",
        "-n", "-f", "pulse", "-i", sink["monitor_source"],
        "-map", "0:a:0", "-c:a", "libmp3lame", "-q:a", "2", str(filename),
    )
    try:
        state.write_text(str(filename) + "\n")
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            if not active():
                break
            if filename.exists():
                notify("Recording system audio", "Press Super+U again to save and copy. Microphone is not recorded.")
                return
            time.sleep(0.1)
        raise RuntimeError(f"Recorder did not start. Check journalctl --user -u {UNIT}")
    except Exception:
        subprocess.run(["systemctl", "--user", "stop", UNIT], check=False, timeout=20)
        state.unlink(missing_ok=True)
        raise


def main() -> None:
    for command in ("ffmpeg", "ffprobe", "pactl", "wl-copy", "notify-send", "systemctl", "systemd-run"):
        if not shutil.which(command):
            raise RuntimeError(f"Missing command: {command}")
    if not os.environ.get("XDG_RUNTIME_DIR"):
        raise RuntimeError("Run this from your desktop session (XDG_RUNTIME_DIR is missing)")
    directory = Path(os.environ["XDG_RUNTIME_DIR"]) / "hypr-audio-recorder"
    directory.mkdir(mode=0o700, exist_ok=True)
    with (directory / "lock").open("w") as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return  # Ignore repeated presses while starting or finalizing.
        state = directory / "recording"
        if state.exists():
            stop_recording(state)
        elif active():
            raise RuntimeError(f"Recording state is missing; stop it with systemctl --user stop {UNIT}")
        else:
            start_recording(state)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        detail = error.stderr.strip() if isinstance(error, subprocess.CalledProcessError) else str(error)
        print(detail, file=sys.stderr)
        if shutil.which("notify-send"):
            notify("Audio recording failed", detail, error=True)
        sys.exit(1)
