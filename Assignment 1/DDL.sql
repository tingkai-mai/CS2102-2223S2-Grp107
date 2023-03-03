CREATE TABLE Employees (
  employeeID INT,
  ename VARCHAR NOT NULL,
  gender VARCHAR,
  dateOfBirth DATE,
  title VARCHAR,
  salary INT,
  PRIMARY KEY (employeeID)
);

CREATE TABLE Customers (
  customerID INT,
  cname VARCHAR NOT NULL,
  gender VARCHAR,
  phoneNumber INT,
  PRIMARY KEY (customerID)
);

CREATE TABLE DeliveryRequests (
  requestID INT,
  customerID INT NOT NULL,
  employeeID INT NOT NULL, 
  pickupAddress VARCHAR NOT NULL,
  pickupPostalCode INT NOT NULL,
  recipientName VARCHAR,
  recipientAddress VARCHAR NOT NULL,
  recipientPostalCode INT NOT NULL,
  PRIMARY KEY (requestID),
  FOREIGN KEY (customerID) REFERENCES Customers (customerID),
  FOREIGN KEY (employeeID) REFERENCES Employees (employeeID)
); 

CREATE TABLE DeliveryProcesses (
  requestID INT, 
  deliveryProcessID INT,
  employeeID INT NOT NULL,
  PRIMARY KEY (requestID, deliveryProcessID),
  FOREIGN KEY (requestID) REFERENCES DeliveryRequests (requestID),
  FOREIGN KEY (employeeID) REFERENCES Employees (employeeID)
);

CREATE TABLE ReturnDeliveryProcesses (
  requestID INT, 
  deliveryProcessID INT,
  PRIMARY KEY (requestID, deliveryProcessID),
  FOREIGN KEY (requestID, deliveryProcessID) REFERENCES DeliveryProcesses (requestID, deliveryProcessID)
);

CREATE TABLE Facilities (
  facilityID INT,
  address VARCHAR NOT NULL,
  postalCode INT NOT NULL,
  PRIMARY KEY (facilityID)
);

CREATE TABLE Packages (
  requestID INT,
  packageID INT,
  height NUMERIC NOT NULL,  
  width NUMERIC NOT NULL,
  package_depth NUMERIC NOT NULL,
  weight NUMERIC NOT NULL, 
  contentDescription VARCHAR NOT NULL,
  estimatedValue NUMERIC NOT NULL,
  PRIMARY KEY (requestID, packageID),
  FOREIGN KEY (requestID) REFERENCES DeliveryRequests (requestID)
);

CREATE TABLE AcceptableRequests (
  requestID INT,
  deliveryPrice NUMERIC NOT NULL,
  tentativePickupDate DATE,
  estimatedDaysToDelivery INT,
  PRIMARY KEY (requestID),
  FOREIGN KEY (requestID) REFERENCES DeliveryRequests (requestID)
);

CREATE TABLE AcceptedRequests (
  requestID INT,
  requestStatus VARCHAR NOT NULL,
  creditCardNumber INT NOT NULL,
  cancellationTimestamp TIMESTAMP,
  paymentTimestamp TIMESTAMP NOT NULL,
  PRIMARY KEY (requestID),
  FOREIGN KEY (requestID) REFERENCES AcceptableRequests (requestID),
  CHECK (requestStatus IN ('CANCELLED', 'COMPLETED', 'IN PROGRESS', 'UNSUCCESSFUL'))
);

CREATE TABLE Legs (
  requestID INT, 
  deliveryProcessID INT,  
  legID INT, 
  employeeID INT NOT NULL, 
  startingTimestamp TIMESTAMP NOT NULL,
  endingTimestamp TIMESTAMP NOT NULL, 
  PRIMARY KEY (requestID, deliveryProcessID, legID),
  FOREIGN KEY (requestID, deliveryProcessID) REFERENCES DeliveryProcesses (requestID, deliveryProcessID),
  FOREIGN KEY (employeeID) REFERENCES Employees (employeeID)
);

CREATE TABLE CustToFacLegs (
  requestID INT, 
  deliveryProcessID INT,  
  legID INT, 
  srcAddr VARCHAR NOT NULL, 
  destFacilityID INT NOT NULL,
  PRIMARY KEY (requestID, deliveryProcessID, legID),
  FOREIGN KEY (requestID, deliveryProcessID, legID) REFERENCES Legs (requestID, deliveryProcessID, legID),
  FOREIGN KEY (destFacilityID) REFERENCES Facilities (facilityID)
);

CREATE TABLE MeasuresPackage ( 
  packageRequestID INT,
  legRequestID INT NOT NULL, 
  deliveryProcessID INT NOT NULL,  
  legID	INT NOT NULL, 
  packageID INT, 
  height NUMERIC NOT NULL,
  width NUMERIC NOT NULL, 
  package_depth NUMERIC NOT NULL,
  weight NUMERIC NOT NULL,
  PRIMARY KEY (packageRequestID, packageID),
  FOREIGN KEY (legRequestID, deliveryProcessID, legID) REFERENCES CustToFacLegs (requestID, deliveryProcessID, legID),
  FOREIGN KEY (packageRequestID, packageID) REFERENCES Packages (requestID, packageID),
  CHECK (packageRequestID = legRequestID)
); 

CREATE TABLE FacToFacLegs (
  requestID INT, 
  deliveryProcessID INT,  
  legID INT,
  srcFacilityID INT NOT NULL,
  destFacilityID INT NOT NULL,
  PRIMARY KEY (requestID, deliveryProcessID, legID),
  FOREIGN KEY (requestID, deliveryProcessID, legID) REFERENCES Legs (requestID, deliveryProcessID, legID),
  FOREIGN KEY (srcFacilityID) REFERENCES Facilities (facilityID),
  FOREIGN KEY (destFacilityID) REFERENCES Facilities (facilityID)
);

CREATE TABLE UnsuccessfulLegs (
  requestID INT, 
  deliveryProcessID INT,  
  legID INT,
  reasonOfFailure VARCHAR NOT NULL,
  PRIMARY KEY (requestID, deliveryProcessID, legID),
  FOREIGN KEY (requestID, deliveryProcessID, legID) REFERENCES FacToFacLegs (requestID, deliveryProcessID, legID)
);

CREATE TABLE FacToCustLegs (
  requestID INT, 
  deliveryProcessID INT,  
  legID INT,
  srcFacilityID INT NOT NULL,
  destAddr VARCHAR NOT NULL, -- cannot enforce
  PRIMARY KEY (requestID, deliveryProcessID, legID),
  FOREIGN KEY (requestID, deliveryProcessID, legID) REFERENCES Legs (requestID, deliveryProcessID, legID),
  FOREIGN KEY (srcFacilityID) REFERENCES Facilities (facilityID)
);

CREATE TABLE LegPrecedes (
  prevRequestID INT, 
  prevDeliveryProcessID INT,  
  prevLegID INT,
  nextRequestID INT, 
  nextDeliveryProcessID INT,  
  nextLegID INT,
  PRIMARY KEY (prevRequestID, prevDeliveryProcessID, prevLegID, nextRequestID, nextDeliveryProcessID, nextLegID),
  FOREIGN KEY (prevRequestID, prevDeliveryProcessID, prevLegID) REFERENCES Legs (requestID, deliveryProcessID, legID),
  FOREIGN KEY (nextRequestID, nextDeliveryProcessID, nextLegID) REFERENCES Legs (requestID, deliveryProcessID, legID)
);

CREATE TABLE UnsuccessfulPickups (
  requestID INT,
  pickupID INT,
  employeeID INT NOT NULL, 
  pickupTimestamp TIMESTAMP NOT NULL,
  reason VARCHAR NOT NULL,
  PRIMARY KEY (requestID, pickupID),
  FOREIGN KEY (requestID) REFERENCES AcceptableRequests (requestID),
  FOREIGN KEY (employeeID) REFERENCES Employees (employeeID)
);
