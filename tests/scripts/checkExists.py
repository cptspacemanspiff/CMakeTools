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
    args = parser.parse_args()



    success = True

    if args.exists:
        for files in args.filenames:
            path = Path(files)
        # we are checking if the file exists
            if not path.exists():
                success = False
                print(f"Error: file {path} does not exist.")
    
    # invert for return
    exit(not success)
