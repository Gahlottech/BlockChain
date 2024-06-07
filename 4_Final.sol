//Student system
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentSystem {
    struct Student {
        string name;
        uint256 age;
        string course;
        uint256 enrollmentYear;
    }

    mapping(address => Student) public students;
    address[] public studentAddresses;

    event StudentRegistered(address indexed studentAddress, string name, uint256 age, string course, uint256 enrollmentYear);
    event StudentUpdated(address indexed studentAddress, string name, uint256 age, string course, uint256 enrollmentYear);

    function registerStudent(string memory _name, uint256 _age, string memory _course, uint256 _enrollmentYear) public {
        require(bytes(_name).length > 0, "Name is required");
        require(_age > 0, "Age must be greater than zero");
        require(bytes(_course).length > 0, "Course is required");
        require(_enrollmentYear > 0, "Enrollment year must be greater than zero");

        Student memory newStudent = Student({
            name: _name,
            age: _age,
            course: _course,
            enrollmentYear: _enrollmentYear
        });

        students[msg.sender] = newStudent;
        studentAddresses.push(msg.sender);

        emit StudentRegistered(msg.sender, _name, _age, _course, _enrollmentYear);
    }

    function updateStudent(string memory _name, uint256 _age, string memory _course, uint256 _enrollmentYear) public {
        require(bytes(_name).length > 0, "Name is required");
        require(_age > 0, "Age must be greater than zero");
        require(bytes(_course).length > 0, "Course is required");
        require(_enrollmentYear > 0, "Enrollment year must be greater than zero");

        Student storage student = students[msg.sender];
        require(bytes(student.name).length > 0, "Student not registered");

        student.name = _name;
        student.age = _age;
        student.course = _course;
        student.enrollmentYear = _enrollmentYear;

        emit StudentUpdated(msg.sender, _name, _age, _course, _enrollmentYear);
    }

    function getStudent(address _studentAddress) public view returns (string memory, uint256, string memory, uint256) {
        Student storage student = students[_studentAddress];
        require(bytes(student.name).length > 0, "Student not registered");

        return (student.name, student.age, student.course, student.enrollmentYear);
    }

    function getAllStudents() public view returns (address[] memory) {
        return studentAddresses;
    }
}


**************************************************************************************************************************************************************************************
//Voter System
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VoterSystem {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool authorized;
        bool voted;
        uint vote;
    }

    address public electionOfficer;
    string public electionName;
    uint public totalVotes;

    mapping(address => Voter) public voters;
    Candidate[] public candidates;

    event ElectionStarted(string electionName);
    event VoterAuthorized(address voter);
    event VoteCasted(address voter, uint candidateId);

    modifier onlyOfficer() {
        require(msg.sender == electionOfficer, "Only the election officer can perform this action");
        _;
    }

    constructor(string memory _electionName) {
        electionOfficer = msg.sender;
        electionName = _electionName;
        emit ElectionStarted(_electionName);
    }

    function addCandidate(string memory _name) public onlyOfficer {
        candidates.push(Candidate(candidates.length, _name, 0));
    }

    function authorizeVoter(address _voter) public onlyOfficer {
        require(!voters[_voter].authorized, "Voter is already authorized");
        voters[_voter].authorized = true;
        emit VoterAuthorized(_voter);
    }

    function vote(uint _candidateId) public {
        require(voters[msg.sender].authorized, "You are not authorized to vote");
        require(!voters[msg.sender].voted, "You have already voted");
        require(_candidateId < candidates.length && _candidateId >= 0, "Invalid candidate ID");

        voters[msg.sender].vote = _candidateId;
        voters[msg.sender].voted = true;
        candidates[_candidateId].voteCount++;
        totalVotes++;

        emit VoteCasted(msg.sender, _candidateId);
    }

    function getCandidate(uint _candidateId) public view returns (uint, string memory, uint) {
        require(_candidateId < candidates.length && _candidateId >= 0, "Invalid candidate ID");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }

    function getTotalCandidates() public view returns (uint) {
        return candidates.length;
    }

    function getElectionResults() public view returns (Candidate[] memory) {
        return candidates;
    }
}

***************************************************************************************************************************************************************************

//Bank system

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    mapping(address => uint256) private balances;
    mapping(address => uint256) private lockTimestamp;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    // Function to deposit Ether into the bank
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        
        balances[msg.sender] += msg.value;
        lockTimestamp[msg.sender] = block.timestamp;
        
        emit Deposit(msg.sender, msg.value);
    }

    // Function to withdraw Ether from the bank
    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        require(block.timestamp >= lockTimestamp[msg.sender] + 5 minutes, "Funds are locked");

        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        
        emit Withdraw(msg.sender, _amount);
    }

    // Function to check the balance of the caller
    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    // Function to check the lock timestamp of the caller
    function getLockTimestamp() public view returns (uint256) {
        return lockTimestamp[msg.sender];
    }
}

***************************************************************************************************************************************************************************************
//Hotel System
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HotelSystem {
    bool public roomAvailable;
    uint256 public pricePerDay;
    address public guest;
    uint256 public reservationDays;

    event RoomReserved(address indexed guest, uint256 reservationDays, uint256 totalCost);
    event RefundIssued(address indexed guest, uint256 refundAmount);

    constructor(uint256 _pricePerDay) {
        roomAvailable = true;
        pricePerDay = _pricePerDay;
    }

    function reserveRoom(uint256 _reservationDays) public payable {
        require(roomAvailable, "Room not available");
        uint256 totalCost = _reservationDays * pricePerDay;
        require(msg.value >= totalCost, "Insufficient payment");

        roomAvailable = false;
        guest = msg.sender;
        reservationDays = _reservationDays;

        emit RoomReserved(msg.sender, _reservationDays, totalCost);

        // Refund excess payment
        if (msg.value > totalCost) {
            uint256 refundAmount = msg.value - totalCost;
            payable(msg.sender).transfer(refundAmount);
            emit RefundIssued(msg.sender, refundAmount);
        }
    }

    function checkout() public {
        require(msg.sender == guest, "Only the guest can checkout");
        require(!roomAvailable, "Room is already available");

        roomAvailable = true;
        guest = address(0);
        reservationDays = 0;
    }

    function getReservationDetails() public view returns (address, uint256) {
        return (guest, reservationDays);
    }
}

**************************************************************************************************************************************************************************************
//Hospital System
pragma solidity ^0.8.0;

contract HospitalSystem {
    struct Doctor {
        string name;
        bool available;
        uint256 consultationFee;
    }

    struct Appointment {
        address patient;
        uint256 doctorId;
        uint256 date; // UNIX timestamp
        bool confirmed;
    }

    Doctor[] public doctors;
    mapping(address => Appointment) public appointments;
    mapping(address => uint256) public balances;

    event DoctorAdded(uint256 doctorId, string name, uint256 consultationFee);
    event AppointmentBooked(address indexed patient, uint256 doctorId, uint256 date);
    event AppointmentConfirmed(address indexed patient, uint256 doctorId, uint256 date);
    event AppointmentCancelled(address indexed patient, uint256 doctorId, uint256 date);
    event PaymentRefunded(address indexed patient, uint256 amount);

    function addDoctor(string memory _name, uint256 _consultationFee) public {
        doctors.push(Doctor({
            name: _name,
            available: true,
            consultationFee: _consultationFee
        }));
        emit DoctorAdded(doctors.length - 1, _name, _consultationFee);
    }

    function bookAppointment(uint256 _doctorId, uint256 _date) public payable {
        require(_doctorId < doctors.length, "Invalid doctor ID");
        require(doctors[_doctorId].available, "Doctor not available");
        require(msg.value >= doctors[_doctorId].consultationFee, "Insufficient payment");

        // Refund excess payment
        if (msg.value > doctors[_doctorId].consultationFee) {
            payable(msg.sender).transfer(msg.value - doctors[_doctorId].consultationFee);
        }

        appointments[msg.sender] = Appointment({
            patient: msg.sender,
            doctorId: _doctorId,
            date: _date,
            confirmed: false
        });

        doctors[_doctorId].available = false;
        balances[address(this)] += doctors[_doctorId].consultationFee;

        emit AppointmentBooked(msg.sender, _doctorId, _date);
    }

    function confirmAppointment(address _patient) public {
        require(appointments[_patient].patient == _patient, "No appointment found");
        appointments[_patient].confirmed = true;

        emit AppointmentConfirmed(_patient, appointments[_patient].doctorId, appointments[_patient].date);
    }

    function cancelAppointment() public {
        Appointment memory appointment = appointments[msg.sender];
        require(appointment.patient == msg.sender, "No appointment found");

        uint256 refundAmount = doctors[appointment.doctorId].consultationFee;
        delete appointments[msg.sender];
        doctors[appointment.doctorId].available = true;

        payable(msg.sender).transfer(refundAmount);
        balances[address(this)] -= refundAmount;

        emit AppointmentCancelled(msg.sender, appointment.doctorId, appointment.date);
        emit PaymentRefunded(msg.sender, refundAmount);
    }

    function getDoctor(uint256 _doctorId) public view returns (string memory, bool, uint256) {
        require(_doctorId < doctors.length, "Invalid doctor ID");
        Doctor memory doc = doctors[_doctorId];
        return (doc.name, doc.available, doc.consultationFee);
    }
    function getAppointment(address _patient) public view returns (uint256, uint256, bool) {
        Appointment memory appointment = appointments[_patient];
        return (appointment.doctorId, appointment.date, appointment.confirmed);
    }
}
******************************************************************************************************************************************************************************************
//Ecommerce
pragma solidity ^0.8.0;

contract Ecommerce {
    address public owner;

    struct Product {
        uint256 id;
        string name;
        uint256 price;
        uint256 stock;
    }

    struct Order {
        uint256 orderId;
        uint256 productId;
        address buyer;
        uint256 quantity;
        uint256 totalPrice;
    }

    uint256 public productCounter = 0;
    uint256 public orderCounter = 0;

    mapping(uint256 => Product) public products;
    mapping(uint256 => Order) public orders;
    mapping(address => uint256[]) public userOrders;

    event ProductAdded(uint256 id, string name, uint256 price, uint256 stock);
    event ProductPurchased(uint256 orderId, uint256 productId, address buyer, uint256 quantity, uint256 totalPrice);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addProduct(string memory _name, uint256 _price, uint256 _stock) public onlyOwner {
        require(_price > 0, "Price should be greater than 0");
        require(_stock > 0, "Stock should be greater than 0");

        productCounter++;
        products[productCounter] = Product(productCounter, _name, _price, _stock);
        
        emit ProductAdded(productCounter, _name, _price, _stock);
    }

    function purchaseProduct(uint256 _productId, uint256 _quantity) public payable {
        require(_productId > 0 && _productId <= productCounter, "Product does not exist");
        require(_quantity > 0, "Quantity should be greater than 0");

        Product memory product = products[_productId];
        uint256 totalPrice = product.price * _quantity;
        require(msg.value >= totalPrice, "Insufficient payment");
        require(product.stock >= _quantity, "Not enough stock");

        product.stock -= _quantity;
        products[_productId] = product;

        orderCounter++;
        orders[orderCounter] = Order(orderCounter, _productId, msg.sender, _quantity, totalPrice);
        userOrders[msg.sender].push(orderCounter);

        // Refund excess payment
        if (msg.value > totalPrice) {
            payable(msg.sender).transfer(msg.value - totalPrice);
        }

        emit ProductPurchased(orderCounter, _productId, msg.sender, _quantity, totalPrice);
    }

    function getUserOrders(address _user) public view returns (uint256[] memory) {
        return userOrders[_user];
    }

    function getOrderDetails(uint256 _orderId) public view returns (Order memory) {
        require(_orderId > 0 && _orderId <= orderCounter, "Order does not exist");
        return orders[_orderId];
    }
}
*************************************************************************************************************************************************
//Shop system
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Shop {
    address public owner;
    
    struct Item {
        string name;
        uint256 price;
        uint256 quantity;
    }
    
    mapping(uint256 => Item) public items;
    uint256 public itemCount;

    event ItemAdded(uint256 itemId, string name, uint256 price, uint256 quantity);
    event ItemPurchased(uint256 itemId, address buyer, uint256 quantity);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addItem(string memory _name, uint256 _price, uint256 _quantity) public onlyOwner {
        itemCount++;
        items[itemCount] = Item(_name, _price, _quantity);
        emit ItemAdded(itemCount, _name, _price, _quantity);
    }

    function buyItem(uint256 _itemId, uint256 _quantity) public payable {
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "Item does not exist");
        require(item.quantity >= _quantity, "Not enough quantity available");
        require(msg.value >= item.price * _quantity, "Insufficient payment");

        item.quantity -= _quantity;
        payable(owner).transfer(msg.value);

        emit ItemPurchased(_itemId, msg.sender, _quantity);

        // Refund excess payment
        if (msg.value > item.price * _quantity) {
            payable(msg.sender).transfer(msg.value - item.price * _quantity);
        }
    }
}
*******************************************************************************************************************************************************
