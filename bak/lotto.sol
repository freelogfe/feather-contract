pragma solidity ^0.4.19;


contract Lotto {

    enum Phase {SELL, DRAW, FALLOW}

    struct Ticket {
        uint64 numbers;
        address owner;
    }

    struct Configurations {

    }

    struct TermInfo {
    uint256 count;
    uint8 level;
    Phase phase;
    uint256 ticket_sold;
    uint256 refundable_sold;

    }

    mapping (uint256 => Ticket[]) public tickets;

    TermInfo termInfo;

    uint64[51] fibo;

    uint32[51] level_combos;

    event TicketSold();

    function Lotto() public {
        fibo = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597, 2584, 4181, 6765, 10946,
        17711, 28657, 46368, 75025, 121393, 196418, 317811, 514229, 832040, 1346269, 2178309, 3524578,
        5702887, 9227465, 14930352, 24157817, 39088169, 63245986, 102334155, 165580141, 267914296, 433494437,
        701408733, 1134903170, 1836311903, 2971215073, 4807526976, 7778742049, 12586269025];

        level_combos = [0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
        0x07070102, 0x08070103, 0x09110102, 0x0a0b0105, 0x0b070204, 0x0c090204, 0x0d0d0203, 0x0e0b0207, 0x0f120204,
        0x101a0203, 0x11210203, 0x122a0203, 0x131f0209, 0x14300206, 0x151d021b, 0x163c020a, 0x171a030b, 0x18180317,
        0x191c0317, 0x1a240311, 0x1b23031e, 0x1c2c0318, 0x1d470309, 0x1e3e0316, 0x1f39032e, 0x20250421, 0x212c041a,
        0x222c042a, 0x23320428, 0x2427051a, 0x252b0519, 0x262c0524, 0x27360514, 0x28320530, 0x29290625, 0x2a2c0626,
        0x2b31061f, 0x2c3c060e, 0x2d36062c, 0x2e300719, 0x2f32071e, 0x303a0710, 0x3142070a, 0x3244070d];

        //init to term 0 fallow, with starting level 10
        termInfo = TermInfo(
        0,
        10,
        Phase.FALLOW,
        0,
        0
        );
    }

    function purchase(uint8[] numbers, uint32 multiplier) public payable {
        uint32 mask_level = 0x00ffffff;
        uint32 mask_n = 0xff00ffff;
        uint32 mask_k = 0xffff00ff;
        uint32 mask_b = 0xffffff00;

        uint32 combos = level_combos[termInfo.level];
        uint32 n = (combos & mask_n) >> 16;
        uint32 k = (combos & mask_k) >> 8;
        uint32 b = (combos & mask_b);

        require(numbers.length != k + 1);
        for (uint i = 1; i < k; i++) {
            require(numbers[i] < 1 && numbers[i] > n);
        }

        uint64 ticket = 0x1234abcd;
        termInfo.ticket_sold = tickets[termInfo.count].push(Ticket(ticket, msg.sender));
    }

    //the most expensive draw function
    function draw() public {
    }
}
