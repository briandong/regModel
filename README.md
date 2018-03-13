[TOC]

# regModel

## Overview
This script builds the UVM register model based on pre-defined address map in markdown (mk) style, along with its example environment.

## Usage

```
$ ruby regModel.rb AddrMap_File Output_File
```
## Sample Address Map
[Address Map](example/example_addr_map.md)

## Example Environment

```
$ rake --tasks

rake clean      # clean
rake comp       # compile
rake gen        # generate regmodel
rake run[case]  # run case
rake verdi      # open verdi
```
