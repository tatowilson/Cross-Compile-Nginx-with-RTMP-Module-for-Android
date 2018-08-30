#!/bin/sh

p_find() {
    case $(uname) in
        Darwin*)
            find -E . -regex $1
            ;;
        Linux*)
            find . -regex $1
            ;;
    esac
}