"""
fabo is Esperanto for 'bean', as in bean counter, or accounting
Run using: 
   mython fabo
"""

import argparse
import glob

import mython.fabo.hdf
import mython.fabo.yahoo
import mython.pytext

def match(line):
    keywords = ["comm", "etran"]
    for k in keywords:
        k = k + " "
        if len(k) >= len(line): continue
        if k == line[0:len(k)]: return True
    return False

def make_auto_etrans():
    root = "/home/mcarter/redact/docs/accts2014"
    files = glob.glob(root + "/companies/*")
    output = ["""#autogenerated - do not edit. Run 'fabo' instead"""]
    for f in files:
        for line in open(f):
            line = line.strip()
            #print(type(line))
            if match(line): output.append(line)
            #if "etran" in line:
            #    output.append(line)

    output.append("") # work around ssa bug of last line requiring a line termination
    mython.pytext.writelines(root + "/data/etrans-auto.txt", output)
                      

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("-d", action = "store_true", help="dump arguments and quit")
    p.add_argument("--snap", action = "store_true", 
                   help = "Daily snapshot from CACHED quantities")
    args = p.parse_args()
    if args.d: print(args) ; quit(0)
    if args.snap: mython.fabo.yahoo.main() ; quit(0)
    
    make_auto_etrans()
    #mython.fabo.hdf.main()
