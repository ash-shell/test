##################################################
# Returns a unicode 'HEAVY CHECK MARK'
##################################################
Test__print_green_check() {
    echo -ne '\033[0;32m'
    echo -ne '\xe2\x9c\x94'
    echo -ne '\033[1;0m'
}

##################################################
# Returns a unicode 'HEAVY BALLOT X'
##################################################
Test__print_red_x() {
    echo -ne '\033[1;31m'
    echo -ne "\xe2\x9c\x98"
    echo -ne '\033[1;0m'
}

##################################################
# Returns a unicode 'RIGHTWARDS ARROW'
##################################################
Test__print_red_rightwards_arrow() {
    echo -ne '\033[1;31m'
    echo -ne "\xe2\x86\x92"
    echo -ne '\033[1;0m'
}
