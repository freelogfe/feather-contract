pragma solidity ^0.4.18;


contract Managed {
    mapping (address => bool) public isManager;

    mapping (address => bool) public isAdministrator;

    address public heir;

    address public admin;

    event Hired(address indexed manager);

    event Fired(address indexed ex_manager);

    event Abdicated(address indexed old, address indexed _new);

    function Managed() public {
        isAdministrator[msg.sender] = true;
        isManager[msg.sender] = true;
    }

    modifier administrator_only() {
        require(isAdministrator[msg.sender]);
        _;
    }

    modifier official_only() {
        require(isManager[msg.sender]);
        _;
    }

    function hire_manager(address new_manager) administrator_only public {
        isManager[new_manager] = true;
        Hired(new_manager);
    }

    function fire_manager(address ex_manager) administrator_only public {
        isManager[ex_manager] = false;
        Fired(ex_manager);
    }

    function demise(address new_admin) administrator_only public {
        require(isManager[new_admin]);
        heir = new_admin;
    }

    function succeed() public {
        require(msg.sender == heir);
        isAdministrator[admin] = false;
        isAdministrator[heir] = true;
        Abdicated(admin, heir);
        admin = heir;
        heir = 0;
    }
}
