Solidity

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract InteractiveARVRModuleParser {
    using SafeMath for uint256;

    struct Module {
        uint256 id;
        string name;
        string description;
        string arVRModel; // AR/VR model file URI
        uint256[] tags; // related tags for the module
        uint256 rating; // rating from 1-5
        address creator;
        uint256 createdAt;
    }

    struct Tag {
        uint256 id;
        string name;
        uint256 count; // number of modules associated with this tag
    }

    mapping (uint256 => Module) public modules;
    mapping (uint256 => Tag) public tags;
    uint256 public moduleIdCounter;
    uint256 public tagIdCounter;

    event ModuleCreated(uint256 moduleId, address creator);
    event ModuleRated(uint256 moduleId, uint256 rating);
    event TagCreated(uint256 tagId, string tagName);

    function createModule(string memory _name, string memory _description, string memory _arVRModel, uint256[] memory _tags) public {
        moduleIdCounter = moduleIdCounter.add(1);
        uint256 moduleId = moduleIdCounter;
        modules[moduleId] = Module(moduleId, _name, _description, _arVRModel, _tags, 0, msg.sender, block.timestamp);
        emit ModuleCreated(moduleId, msg.sender);
        for (uint256 i = 0; i < _tags.length; i++) {
            uint256 tagId = _tags[i];
            if (tags[tagId].id == 0) {
                tagIdCounter = tagIdCounter.add(1);
                tags[tagIdCounter] = Tag(tagIdCounter, _arVRModel, 1);
                emit TagCreated(tagIdCounter, _arVRModel);
            } else {
                tags[tagId].count = tags[tagId].count.add(1);
            }
        }
    }

    function rateModule(uint256 _moduleId, uint256 _rating) public {
        require(modules[_moduleId].id != 0, "Module does not exist");
        require(_rating >= 1 && _rating <= 5, "Invalid rating");
        modules[_moduleId].rating = _rating;
        emit ModuleRated(_moduleId, _rating);
    }

    function getModulesByTag(uint256 _tagId) public view returns (uint256[] memory) {
        uint256[] memory moduleIds = new uint256[](10); // assuming max 10 modules per tag
        uint256 count = 0;
        for (uint256 i = 1; i <= moduleIdCounter; i++) {
            if (contains(modules[i].tags, _tagId)) {
                moduleIds[count] = i;
                count++;
            }
        }
        return moduleIds;
    }

    function contains(uint256[] memory _array, uint256 _value) internal pure returns (bool) {
        for (uint256 i = 0; i < _array.length; i++) {
            if (_array[i] == _value) {
                return true;
            }
        }
        return false;
    }
}