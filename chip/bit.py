"""Bit manipulation module from https://wiki.python.org/moin/BitManipulation"""
import math


def bin( s):
    return str( s) if s <= 1 else bin( s >> 1) + str( s & 1)


def len( int_type):
    length = 0
    while( int_type):
        int_type >>= 1
        length += 1
    return length


def lenCount( int_type):
    length = 0
    count  = 0
    while( int_type):
        count += int_type & 1
        int_type >>= 1
        length += 1
    return ( length, count)


def count( int_type):
    count = 0
    while( int_type):
        int_type &= int_type - 1
        count += 1
    return count
    

def parity( int_type):
    parity = 0
    while ( int_type):
        parity = ~parity
        int_type = int_type & ( int_type - 1)
    return parity


def lowestSet( int_type):
    low = int_type & -int_type
    lowBit = -1
    while ( low):
        low >>= 1
        lowBit += 1
    return lowBit


def test( int_type, offset):
    mask = 1 << offset
    return ( int_type & mask)


def set( int_type, offset):
    mask = 1 << offset
    return ( int_type | mask)


def clear( int_type, offset):
    mask = ~( 1 << offset)
    return ( int_type & mask)


def toggle( int_type, offset):
    mask = 1 << offset
    return ( int_type ^ mask)
