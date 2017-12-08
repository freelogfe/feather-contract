pragma solidity ^0.4.18;


contract Managed {
    mapping (address => bool) public isManager;

    mapping (address => bool) public isAdministrator;

    //超级管理员继承人
    address public heir;
    //当前超级管理员
    address public admin;

    event Hired(address indexed manager);

    event Fired(address indexed ex_manager);

    event Abdicated(address indexed old, address indexed _new);

    function Managed() public {
        admin = msg.sender;
        isAdministrator[msg.sender] = true;
        isManager[msg.sender] = true;
    }

    modifier administrator_only() {
        require(isAdministrator[msg.sender]);
        _;
    }

    modifier official_only() {
        //普通管理员和超级管理员的操作均可以认为是官方操作
        require(isManager[msg.sender] || isAdministrator[msg.sender]);
        _;
    }

    //超管指定管理员
    function hire_manager(address new_manager) administrator_only public {
        isManager[new_manager] = true;
        Hired(new_manager);
    }

    //超管取消管理员
    function fire_manager(address ex_manager) administrator_only public {
        isManager[ex_manager] = false;
        Fired(ex_manager);
    }

    //超管指定继承人
    function demise(address new_admin) administrator_only public {
        //是否从管理员委员会指定,暂时未定
        require(isManager[new_admin]);
        heir = new_admin;
    }

    //继承人确认继承超级管理员
    function succeedAdmin() public {
        require(msg.sender == heir);
        isAdministrator[admin] = false;
        isAdministrator[heir] = true;
        Abdicated(admin, heir);
        admin = heir;
        heir = 0;
    }
}
