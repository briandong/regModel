[TOC]

# Address Map

BaseAddr: 'h100
Width(B): 4

## Register List

> Access: 
> Volatile: 

### ID

Offset: 'h0
Size(B): 4

|Name|Size|Position|Access|Volatile?|Reset Value|Reset?|Rand?|Individual Access?|Info|
|-|-|-|-|-|-|-|-|-|-|
|PRODUCT_ID|10|16|RO|0|10'h176|1|0|1| |
|CHIP_ID|8|8|RO|0|8'h5A|1|0|1| |
|REVISION_ID|8|0|RO|0|8'h03|1|0|1| |

Rights: RO

### DATA

Offset: 'h4
Size(B): 4

|Name|Size|Position|Access|Volatile?|Reset Value|Reset?|Rand?|Individual Access?|Info|
|-|-|-|-|-|-|-|-|-|-|
|VALUE|32|0|RW|1|32'h0|1|0|1| |

Rights: RW

## Memory List

> Size: specifies the total number of memory items.
> Bites: specifies the number of bits in each memory item.

### RAM

Offset: 'h10

|Name|Size|Bits|Info|
|-|-|-|-|
|RAM|'h400|32| |

Rights: RW
