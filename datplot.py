#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import os
import re
import argparse
import locale
from matplotlib import rc, rcParams
from matplotlib import pyplot as plt


# Hash of global parameters shared between different option handlers,
# with default values.
params = {
    "format"   : "png",
    "encoding" : "utf-8",
    "mirror"   : False }


# Unfortunately, Python syntax disallows assignments in lambdas. So, instead
# of lambda: params[key] = val one have to write lambda: setparam(key, val).
def setparam(name, val):
    params[name] = val


# Decodes string from local encoding to unicode where local encoding is
# specified with '--encoding' switch and is UTF-8 by default.
def decode(s):
    return unicode(s, encoding=params['encoding'])


def readFile(filename):
    datafile = open(filename, "r")
    lines    = datafile.readlines()

    xs = []
    ys = []
    for line in lines:
        res = line.split("\t")
        xs.append(float(res[0]))
        ys.append(float(res[1]))

    return (xs, ys)


def mirror(xs, ys):
    result_x = []
    result_y = []
    for i in xrange(len(xs)):
        x = xs[i]
        y = ys[i]
        result_x.append(x)
        result_y.append(y)

        if i!=0:
            result_x = [-x] + result_x
            result_y = [y]  + result_y

    return (result_x, result_y)


def addhandler(parser, name, nargs=None, type=None, handler=None):
    class PlotAction(argparse.Action):
        def __call__(self, parser, namespace, values, option_string=None):
            handler(*values)

    # Note that 'PlotAction' class is local to 'add' function and gets
    # redefined every time it's called.
    parser.add_argument(name, nargs=nargs, type=type, action=PlotAction)


def plot(f):
    (xs, ys) = readFile(f)
    if params["mirror"]:
        (xs, ys) = mirror(xs, ys)

    plt.plot(xs, ys)


def xcaption(s):
    tickpad  = rcParams['xtick.major.pad']
    fontsize = rcParams['font.size']
    plt.annotate(s, xy=(1,0), xytext=(0, -tickpad - fontsize),
        ha='center',
        va='top',
        xycoords='axes fraction',
        textcoords='offset points')


def ycaption(s):
    tickpad  = rcParams['ytick.major.pad']
    fontsize = rcParams['font.size']
    plt.annotate(s, xy=(0,1), xytext=(-tickpad, (fontsize + tickpad)/2),
        ha='center',
        va='bottom',
        xycoords='axes fraction',
        textcoords='offset points')


# Available command line options, their parameter and handlers.
# This is the list of tuples (name, nargs, type, handler).
options = [
    ("format",      1, None,     lambda v:   setparam("format", v)),
    ("encoding",    1, None,     lambda v:   setparam("encoding", v)),
    ("mirror",      1, bool,     lambda v:   setparam("mirror", v)),
    ("line-color",  1, None,     lambda v:   rc("lines", color=v)),
    ("line-width",  1, None,     lambda v:   rc("lines", width=v)),
    ("line-style",  1, None,     lambda v:   rc("lines", style=v)),
    ("font-family", 1, None,     lambda v:   rc("font",  family=v)),
    ("font-weight", 1, None,     lambda v:   rc("font",  weigth=v)),
    ("font-size",   1, float,    lambda v:   rc("font",  size=v)),
    ("dpi",         1, float,    lambda d:   rc("savefig", dpi=d)),
    ("figsize",     2, float,    lambda x,y: plt.figure(figsize=(x,y))),
    ("grid",        1, bool,     lambda v:   plt.grid(v)),
    ("xlabel",      1, None,     lambda v:   plt.xlabel(decode(v))),
    ("ylabel",      1, None,     lambda v:   plt.ylabel(decode(v))),
    ("xlim",        2, float,    lambda a,b: plt.xlim(a,b)),
    ("ylim",        2, float,    lambda a,b: plt.ylim(a,b)),
    ("xcaption",    1, None,     lambda v:   xcaption(decode(v))),
    ("ycaption",    1, None,     lambda v:   ycaption(decode(v))),
    ("plot",        1, None,     lambda f:   plot(decode(f)))]


# --- main ---
locale.setlocale(locale.LC_ALL, "")
rc("axes.formatter", use_locale=True)

parser = argparse.ArgumentParser()
for (dest, nargs, argtype, handler) in options:
    addhandler(parser, "--%s" % dest, nargs, argtype, handler)

parser.add_argument("outfile")
parser.add_argument("files", nargs='*')

result = parser.parse_args()
for f in result.files:
    plot(decode(f))

plt.savefig(result.outfile, format=params['format'])
