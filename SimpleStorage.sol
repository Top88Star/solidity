// SPDX-License-Identifier: MIT
pragma solidity 0.8.22;

contract SimpleStorage {
    uint256 myFavouriteNumber; //0
    uint256[] listOfFavouriteNumbers; 

    struct Person{
        uint256 favouriteNumber;
        string name;
    }

    //Person public plamen = Person({favouriteNumber: 7, name: "Plamen"});
    //Person public emo = Person({favouriteNumber: 7, name: "Emo"});
    //Person public rosi = Person({favouriteNumber: 7, name: "Rosi"});

    Person[] public listOfPeople; //[]

    //Plamen -> 22
    mapping(string => uint256) public nameToFavouriteNumber;

    function store(uint256 _favouriteNumber) public {
        myFavouriteNumber = _favouriteNumber;
    }

    //0xd9145CCE52D386f254917e481eB44e9943F39138

    function retrieve() public view returns(uint256) {
        return myFavouriteNumber;
    }

    function addPerson(string memory _name, uint256 _favouriteNumber) public {
        
        listOfPeople.push(Person (_favouriteNumber, _name));
        nameToFavouriteNumber[_name] = _favouriteNumber;
    }
}