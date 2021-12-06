#!/usr/bin/env python

"""
Script to batch pitch shift a list of input files by multiple factors.
Preserves tempo and sample rate.

Since all the kiddos are of different ages, we can take a few character sfx
audio files and pitch shift them to simulate the various character voices.

Usage:

    1. Assumptions. I don't want to spend too much time generalizing this script,
       so let's assume the following:

        - Your audio files have encodings that ffmpeg can deal with - ogg, mp3, etc.
        - They are named like "[description]_p1.ogg", where the "p1" means that
          the file hasn't been pitch shifted -- it's the original file. 
            - *This script expects the "_p1", don't omit it!*
            - Example: victory_yell_p1.ogg
        - Your input audio files are in the same folder as this script. You'll move
          these and the resulting output files to where they need to live manually.
    2. Add the requirements in `scripts/requirements.txt` to your python environment.
    3. Run the script from the command line like so:

        ```bash
            python pitch_shift.py victory_yell_p1.ogg 0.5,2.0
        ```

        - The above will halve and double the pitch of "victory_yell_p1.ogg", 
          producing the following output files:

          - victory_yell_p0.5.ogg
          - victory_yell_p2.0.ogg
"""

import os
import ffmpeg
import click

@click.command()
@click.argument("input_files", type=click.STRING)
@click.argument("pitch_factors", type=click.STRING)
@click.option("-y", "--overwrite-existing", is_flag=True, help="Overwrite existing files.")
def pitch_shift(input_files, pitch_factors, overwrite_existing):
    input_files = [str(i) for i in input_files.split(",")]
    pitch_factors = [float(v) for v in pitch_factors.split(",")]
    for infile in input_files:
        file_name, ext = os.path.splitext(infile)
        file_desc = file_name.split("_p1")[0]
        for pf in pitch_factors:
            if overwrite_existing:
                ffmpeg.input(infile)\
                      .filter("asetrate", 48000*pf)\
                      .filter("aresample", 48000)\
                      .filter("atempo", 1/pf)\
                      .output(f"{file_desc}_p{pf}{ext}")\
                      .overwrite_output()\
                      .run()
            else:
                ffmpeg.input(infile)\
                      .filter("asetrate", 48000*pf)\
                      .filter("aresample", 48000)\
                      .filter("atempo", 1/pf)\
                      .output(f"{file_desc}_p{pf}{ext}")\
                      .run()

if __name__ == "__main__":
    pitch_shift()