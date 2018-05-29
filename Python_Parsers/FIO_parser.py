from glob import glob
import csv
import sys

directory = sys.argv[1]

def identify_attrs(filename):
    info_dic = {}
    filename = filename.strip().split("/")[-1:][0]
    info = filename.split(".")
    info_dic = {
        "op_type" : info[0],
        "iodepth" : info[2].split("_")[1],
        "dedup" : info[3].split("_")[1],
        "vdo" : True,
        "op" : info[1]
    }
    return info_dic

def find_bw(file_obj,attributes):
    with open(file_obj) as fio_out:
        for i in fio_out.read().splitlines():
            if ( (i.split("\n")[0].strip(" ").split(" ")[0] == "READ:") or (i.split("\n")[0].strip(" ").split(" ")[0] == "WRITE:") ):
                io_size = i.split("\n")[0].strip(" ").split(" ")[5].split("=")[1]
                attributes["io"] = io_size
                bw = i.split("\n")[0].strip(" ").split(" ")[1].split("=")[1]
                if bw[-5] == "K":
                    bw_in_KiB = float(bw[:-5])
                    attributes["bw"] = round(bw_in_KiB/1024,2)
                elif bw[-5] == "M":
                    attributes["bw"] = float(bw[:-5])
    print attributes
    return attributes

def main():
    list_random_write = []
    list_random_read = []
    list_sequential_write = []
    headers = ["vdo","op_type","op","iodepth","dedup","bw","io"]
    for f in glob(directory+"*"):
        filename = f.strip().split("/")[-1:][0]
        attributes = identify_attrs(filename)
        attributes = find_bw(f,attributes)
        if (attributes["op"] == "write"):
            if (attributes["op_type"] == "random"):
                list_random_write.append(attributes)
            else:
                list_sequential_write.append(attributes)
        else:
            list_random_read.append(attributes)

    with open("csv_file.csv", 'a+') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=headers)
        writer.writeheader()
        for row in list_sequential_write:
            writer.writerow(row)
        writer = csv.DictWriter(csvfile, fieldnames=headers)
        writer.writeheader()
        for row in list_random_read:
            writer.writerow(row)
        writer = csv.DictWriter(csvfile, fieldnames=headers)
        writer.writeheader()
        for row in list_random_write:
            writer.writerow(row)

if __name__ == '__main__':
    main()

