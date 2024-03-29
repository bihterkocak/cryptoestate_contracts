
pragma solidity ^0.4.24;
/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd
interface ERC721 /* is ERC165 */ {

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) public view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public payable;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable;


    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;


    function approve(address _approved, uint256 _tokenId) external payable;


    function setApprovalForAll(address _operator, bool _approved) public;

    function getApproved(uint256 _tokenId) public view returns (address);


    function isApprovedForAll(address _owner, address _operator) public view returns (bool);
    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
}

interface ERC165 {

    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}