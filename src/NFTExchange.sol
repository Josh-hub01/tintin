// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import '@openzeppelin-contracts-5.0.2/token/ERC721/IERC721.sol';
import '@openzeppelin-contracts-5.0.2/utils/ReentrancyGuard.sol';
import '@openzeppelin-contracts-5.0.2/token/ERC20/IERC20.sol';
import '@openzeppelin-contracts-5.0.2/token/ERC721/extensions/ERC721URIStorage.sol';

contract NFTExchange is ReentrancyGuard {
  struct Listing {
    address seller;
    address nftContract;
    uint256 price;
    uint256 tokenId;
    uint256 listTimestamp;
    bool listed;
  }
  
  mapping(address => mapping(uint256 => Listing)) public listings;
  address private owner;
  IERC20 public paymentToken;

  constructor(IERC20 paymentToken_) {
    owner = msg.sender;
    paymentToken = paymentToken_;
  }

  // List NFT
  function listNFT(address nftContract, uint256 tokenId, uint256 price) external returns (Listing memory) {
    ERC721URIStorage nft = ERC721URIStorage(nftContract);

    require(nft.ownerOf(tokenId) == msg.sender, 'Only the owner can list this NFT');

    Listing memory listed = listings[nftContract][tokenId];

    require(!listed.listed, 'This NFT is already listed');

    require(nft.isApprovedForAll(msg.sender, address(this)), 'Contract not approved');

    Listing memory listing = Listing(msg.sender, nftContract, price, tokenId, block.timestamp, true);

    listings[nftContract][tokenId] = listing;

    return listing;
  }

  // Delist NFT
  function delistNFT(address nftContract, uint256 tokenId) public {
    Listing storage listing = listings[nftContract][tokenId];
    require(listing.seller == msg.sender, 'Only the owner can remove this NFT');
    require(listing.listed, 'This NFT is not listed for sale');

    listing.listed = false;

    delete listings[nftContract][tokenId];
  }

  // Buy NFT
  function buyNFT(
    address nftContract_,
    uint256 tokenId_
  ) external nonReentrant {
    Listing storage listing = listings[nftContract_][tokenId_];
    require(listing.listed, 'NFT not listed for sale');
    require(paymentToken.transferFrom(msg.sender, listing.seller, listing.price), 'Payment failed');

    IERC721 nft = IERC721(nftContract_);
    nft.safeTransferFrom(listing.seller, msg.sender, tokenId_);

    listing.listed = false;

    delete listings[nftContract_][tokenId_];
  }

  // Update price
  function updatePrice(address nftContract_, uint256 tokenId_, uint256 newPrice_) public {
    Listing storage listing = listings[nftContract_][tokenId_];
    require(listing.seller == msg.sender, 'Only the owner can update the price');
    require(listing.listed, 'NFT not listed for sale');

    listing.price = newPrice_;
  }
}
