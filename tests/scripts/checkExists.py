#!/usr/bin/python3

from pathlib import Path


def fileExists(fname: Path):


    pass


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        prog="ProgramName",
        description="What the program does",
        epilog="Text at the bottom of help",
    )
    parser.add_argument("filenames",nargs='+')

    parser.add_argument("--exists",action="store_true")

    parser.add_argument("--equals",type=str)

    args = parser.parse_args()

    success = True

    if args.exists:
        for files in args.filenames:
            path = Path(files)
        # we are checking if the file exists
            if not path.exists():
                success = False
                print(f"Error: file {path} does not exist.")

    if args.equals:
        for files in args.filenames:
            with open(files, 'r') as file:
                generatedfile = file.read()
                if not generatedfile == args.equals:
                    success = False
                    print(f"Error, generated file does not match expected contents:\n {generatedfile} \n {args.equals}")
    
    # invert for return
    exit(not success)
