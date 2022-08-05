// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DaisyToken is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // 배포자 address가 담길 contractOwner
    address private contractOwner;

    // 한 유저가 민팅을 한번만 할 수 있도록 기록해주는 변수
    mapping(address => uint256) private _ownerMint;

    // contract 생성한 address를 contractOwner에 저장
    constructor(string memory name, string memory symbol) ERC721(name, symbol) payable {
        contractOwner = msg.sender;
    }

    // itemMint라는 함수를 생성(오직 TokenURI 데이터만을 받는 함수)
    function itemMint(string memory uri) public payable {

        //  함수 호출자가 존재하는지 체크
        require(msg.sender != address(0), "ERC721: mint to the zero address");
        // 민팅에 필요한 0.001 이더가 있는지 확인
        require(msg.value >= 0.001 ether, "Not enough ETH for minting: check price.");
        // 이전에 민팅을 한적이 있는지 확인
        require(_ownerMint[msg.sender] < 1, "ERC721: token already minted");
        
        // TokenId는 한 번 민팅할 때마다 자동으로 1씩 증가
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
    
        // 함수 호출자가 발행한 TokenId를 OwnerMint에 기록하여 추가 발행을 막음
        _ownerMint[msg.sender] = tokenId;

        // 이 함수를 호출한 사람의 주소로 NFT가 민팅되게 설정
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);

        // contractOwner에게 0.001이더를 송금
        payable(contractOwner).transfer(0.001 ether);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory){
        return super.tokenURI(tokenId);
    }    
}
