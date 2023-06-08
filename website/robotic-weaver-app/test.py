import sys
import time


def main():
    # sys.stdout.flush()
    word = sys.argv[1]
    print("start!!!")
    time.sleep(3)
    for i in range(10):
        print("hello, " + word)
    print("done.")


if __name__ == "__main__":
    main()
