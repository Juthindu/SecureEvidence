
App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',
  logoutTimeout: null,
  logoutTimeLimit: 5 * 60 * 1000,

  init: async function() {
    console.log("Initializing App...");
    if (window.ethereum) {
      try {
        App.web3Provider = window.ethereum;
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        web3 = new Web3(window.ethereum);
        console.log("Connected to Ethereum via window.ethereum");
        App.initContract();
      } catch (error) {
        console.error("User denied account access");
      }
    } else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
      web3 = new Web3(window.web3.currentProvider);
      console.log("Connected to Ethereum via window.web3");
      App.initContract();
    } else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
      console.log("Connected to Ethereum via localhost:7545");
      App.initContract();
    }

    ipfs = window.IpfsHttpClient.create({ host: 'localhost', port: '5001', protocol: 'http' });

  },
//DONE
  initContract: function() {
    console.log("Initializing contracts...");

    const contractList = [
      { name: "SecureEvidence", file: "../contracts/SecureEvidence.json" },
      { name: "Case", file: "../contracts/Case.json" },
      { name: "SuperAdmin", file: "../contracts/SuperAdmin.json" },
      { name: "TypeAndId", file: "../contracts/TypeAndId.json" },
      { name: "User", file: "../contracts/User.json" },
    ];

    contractList.forEach(contract => {
      $.getJSON(contract.file, function(data) {
        const contractData = data;
        App.contracts[contract.name] = TruffleContract(contractData);
        App.contracts[contract.name].setProvider(App.web3Provider);
  
        App.contracts[contract.name].deployed().then(function(instance) {
          console.log(`${contract.name} contract deployed at address:`, instance.address);
        }).catch(function(err) {
          console.error(`Error deploying ${contract.name} contract:`, err);
        });
      }).fail(function(jqxhr, textStatus, error) {
        console.error(`Failed to load ${contract.name} contract JSON:`, textStatus, error);
      });
    });
    App.render();
  },

//DONE
  render: function() {
  console.log("Rendering App...");
  const loader = $("#loader");
  const content = $("#content");

  loader.show();
  content.hide();

  const currentPage = window.location.pathname.split("/").pop();

  if (currentPage !== "index.html" && localStorage.getItem('isLoggedIn') !== 'true') {
    console.log("User is not logged in. Redirecting to login page.");
    window.location.href = "index.html";
    return;
  }

  web3.eth.getCoinbase(function(err, account) {
  if (err === null) {
    App.account = account;
    console.log("Account:", App.account);
    if (App.account) {
      $("#accountAddress").html("Your Account: " + App.account);
      if (localStorage.getItem('isLoggedIn') === 'true') {
        $("#loader").hide();
        $("#content").hide();
        
        App.resetLogoutTimer();
      } else {
        $("#loader").hide();
        $("#content").show();
      }
    } else {
      loader.hide();
    }
  } else {
    console.error("Error retrieving account:", err);
    loader.hide();
  }
  });

  window.ethereum.on('accountsChanged', function(accounts) {
    console.log("Accounts changed:", accounts);
    if (accounts.length === 0 || accounts[0] !== App.account) {
      App.logout();
    }
  });

  $("#submitUsername").click(function() {
    const username = $("#username").val();
      if (username !== "") {
        App.login(username);
      } else {
        $("#loginMessage").html("Please enter username");
      }
  });

  $("#logoutButton").click(function() {
    App.logout();
  });
  
  $('#addNewUserForm').submit(function(event) {
    form = '#addNewUserForm';
    event.preventDefault(); 
    App.addUser(form);
  });

  $("#searchUserButton").click(function(event) {
    event.preventDefault();
    App.viewUser(); 
  });

  $("#searchUserForUpdateButton").click(function(event) {
    event.preventDefault();
    App.searchForUpdate(); 
  });

  $('#updateUserForm').submit(function(event) {
    form = '#updateUserForm';
    event.preventDefault(); 
    App.updateUser(form);
  });

  $("#addNewTypeForm").submit(function(event) {
    form = "#addNewTypeForm";
    event.preventDefault(); 
    App.addType(form);
  });

  $("#searchCaseTypeButton").click(function(event) {
    event.preventDefault();
    App.viewType(); 
  });

  $("#addNewCaseForm").submit(function(event) {
    form = "#addNewCaseForm";
    event.preventDefault(); 
    App.addCase(form);
  });

  $("#searchCaseButton").click(function(event) {
    event.preventDefault();
    App.viewCase(); 
  });

  $("#searchCaseForUpdateButton").click(function(event) {
    event.preventDefault();
    App.searchCaseForUpdate(); 
  });

  $('#updateCaseForm').submit(function(event) {
    form = '#updateCaseForm';
    event.preventDefault(); 
    App.updateCase(form);
  });

  $("#addNewEvidenceForm").submit(function(event) {
    form = "#addNewEvidenceForm";
    event.preventDefault(); 
    App.addEvidence(form);
  });

  $("#searchEvidenceButton").click(function(event) {
    event.preventDefault();
    App.viewEvidence(); 
  });

  $("#searchEvidenceForUpdateButton").click(function(event) {
    event.preventDefault();
    App.searchEvidenceForUpdate(); 
  });

  $('#updateEvidenceForm').submit(function(event) {
    form = '#updateEvidenceForm';
    event.preventDefault(); 
    App.updateEvidence(form);
  })

  $("#resetButton").click(function(event) {
    event.preventDefault();
    const form = '#' +this.form.id; 
    App.resetForm(form);
  });

  $('#errorMassageModal').on('click', '.error-button', function() {
    $('#errorMassageModal').modal('hide');
  });

  $("#imageForm").submit(App.uploadImageHandler);

  $("#fetchImageForm").submit(App.fetchImageHandler);

  document.addEventListener('mousemove', App.resetLogoutTimer);
  document.addEventListener('keydown', App.resetLogoutTimer);
  document.addEventListener('click', App.resetLogoutTimer);
  },
  // DONE
  connectAccount: async function() {
    if (typeof window.ethereum !== 'undefined') {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        App.account = accounts[0];
        console.log("Connected account:", App.account);
        $("#accountAddress").html("Your Account: " + App.account);
        $("#loader").hide();
        $("#content").show();
      } catch (error) {
        console.error("User denied account access");
      }
    }
  },
    //DONE
  login: function() {
    const username = $("#username").val();
    if (username === "") {
      $("#loginMessage").html("Please enter username");
      return;
    }
    App.contracts.User.deployed().then(function(instance) {
      return instance.login(username, { from: App.account });
    }).then(function(result) {
      $("#loginMessage").html(result);
      if (result.includes("Welcome")) {
        $("#content").hide();
        $("#page-content").show();
        localStorage.setItem('isLoggedIn', 'true');
        window.location.href = "dashboard.html";
      }
    }).catch(function(error) {
      console.error(error);
      $("#loginMessage").html(error);
    });
  },
  //DONE
  logout: function() {
    console.log("logout");
    localStorage.setItem('isLoggedIn', 'false');
    $("#content").show();
    $("#loginMessage").html("You have logged out.");
    window.location.href = "index.html";
    if (App.logoutTimeout) {
      clearTimeout(App.logoutTimeout); 
    }
  },
  //DONE
  resetLogoutTimer: function() {
    if (App.logoutTimeout) {
      clearTimeout(App.logoutTimeout); 
    }
    App.logoutTimeout = setTimeout(App.logout, App.logoutTimeLimit); 
  },
  //DONE
  resetForm: function(form) { 
    rotateLogo();
    $(form)[0].reset();
    const inputStatus = document.getElementById('inputStatus');
    if (inputStatus) {
      inputStatus.textContent = 'No file selected';
    }
  },
  //DONE
  addUser: async function(form) {
    $('#addNewUserSubmit').prop('disabled', true);
    const name = document.getElementById('name').value;
    const ID = document.getElementById('ID').value;
    const role = document.getElementById('role').value;
    const status = document.getElementById('status').value;
    const username = document.getElementById('username').value;
    const accountAddress = document.getElementById('accountAddress').value;

    console.log('Form submitted:', { name, ID, role, status, username, accountAddress });
    try {
      const instance = await App.contracts.User.deployed();
      const result = await instance.addUser(name, ID, accountAddress, username, status, role, { from: App.account, gas: 500000 });
      console.log('Transaction Hash:', result.tx);

      web3.eth.getTransactionReceipt(result.tx, function(error, receipt) {
        if (error) {
          console.error('Error retrieving transaction receipt:', error);
          showErrorModal('Error retrieving transaction receipt: ' + error.message);
        } else {
          console.log('Transaction Receipt:', receipt);
          if (receipt && receipt.status) {
            console.log('User created successfully');
            showSuccessModal('User created successfully',form);
          } else {
            console.log('Transaction failed or user was not added');
            showErrorModal('Transaction failed or user was not added');
          }
        }
        $('#addNewUserSubmit').prop('disabled', false);
      });
    } catch (error) {
      console.error('Error adding new user:', error);
      showErrorModal('Error adding new user: Please check the data and retry again');
      $('#addNewUserSubmit').prop('disabled', false);
    }
  },
//DONE
  viewUser: async function() {
    $('#searchUserButton').prop('disabled', true);
    const ID = document.getElementById('ID').value;
    
    try {
        const instance = await App.contracts.User.deployed();
        const result = await instance.getUserByID(ID, { from: App.account });
        console.log(result);
        if (result && result[0] && result[1] && result[2] && result[3] && result[4] && result[5]) {

            let Status, Role;
            if (result[4] == 1) {
                Status = "Active";
            } else if (result[4] == 0) {
                Status = "Inactive";
            }
            if (result[5] == 2) {
                Role = "Admin";
            } else if (result[5] == 1) {
                Role = "Level 01";
            } else if (result[5] == 0) {
                Role = "Level 02";
            }

            userTableBody.innerHTML = `
              <tr>
                <td>${result[0]}</td>
                <td>${result[1].toString()}</td>
                <td>${result[2]}</td>
                <td>${result[3]}</td>
                <td>${Status}</td>
                <td>${Role}</td>
              </tr>
            `;
            document.getElementById('userData').style.display = 'block';
        } else {
            console.log('User with ID', ID, 'not found');
            showErrorModal('User with ID ' + ID + ' not found');
        }

    } catch (error) {
        console.error('Error retrieving user data:', error);
        if (error.data.message.includes('User')) {
            showErrorModal('User with ID ' + ID + ' not found');
        } else {
            showErrorModal('Error retrieving user data: ' + error.message);
        }
    } finally {
        $('#searchUserButton').prop('disabled', false);
    }
  },
//DONE
  searchForUpdate: async function() {
    $('#searchUserForUpdateButton').prop('disabled', true);
    const ID = document.getElementById('ID').value;
    
    try {
      const instance = await App.contracts.User.deployed();
      const result = await instance.getUserByID(ID, { from: App.account });
      
      if (result && result[0] && result[1] && result[2] && result[3] && result[4] && result[5]) {
        console.log('User Name:', result[0]);
        console.log('User ID:', result[1].toString()); 
        console.log('User Address:', result[2]);
        console.log('Username:', result[3]);
        console.log('Status:', result[4].toString());
        console.log('Role:', result[5].toString());
        
        document.getElementById('nameValue').value = result[0]; 
        document.getElementById('idValue').value = result[1].toString(); 
        document.getElementById('roleValue').value = result[5].toString(); 
        document.getElementById('statusValue').value = result[4].toString(); 
        document.getElementById('usernameValue').value = result[3]; 
        document.getElementById('accountAddressValue').value = result[2]; 
        
        document.getElementById('userData').style.display = 'block';
      } else {
        console.log('User with ID', ID, 'not found');
        showErrorModal('User with ID ' + ID + ' not found');
      }
  
    } catch (error) {
      console.error('Error retrieving user data:', error);
      if (error.data.message.includes('User')) {
        showErrorModal('User with ID ' + ID + ' not found');
      } else {
        showErrorModal('Error retrieving user data: ' + error.message);
      }
    } finally {
      $('#searchUserForUpdateButton').prop('disabled', false);
    }
  },
//DONE
  updateUser: async function(form) {
    $('#updateUserSubmit').prop('disabled', true);
    const name = document.getElementById('nameValue').value;
    const ID = document.getElementById('idValue').value;
    const role = document.getElementById('roleValue').value;
    const status = document.getElementById('statusValue').value;
    const username = document.getElementById('usernameValue').value;
    const accountAddress = document.getElementById('accountAddressValue').value;

    console.log('Form submitted:', { name, ID, role, status, username, accountAddress });
    try {
      const instance = await App.contracts.User.deployed();
      const result = await instance.updateUser(name, ID, accountAddress, username, status, role, { from: App.account, gas: 500000 });
      console.log('Transaction Hash:', result.tx);

      web3.eth.getTransactionReceipt(result.tx, function(error, receipt) {
        if (error) {
          console.error('Error retrieving transaction receipt:', error);
          showErrorModal('Error retrieving transaction receipt: ' + error.message);
        } else {
          console.log('Transaction Receipt:', receipt);
          if (receipt && receipt.status) {
            console.log('User updated successfully');
            showSuccessModal('User updated successfully',form);
          } else {
            console.log('Transaction failed or user was not added');
            showErrorModal('Transaction failed or user was not added');
          }
        }
        $('#updateUserSubmit').prop('disabled', false);
      });
    } catch (error) {
      console.error('Error adding new user:', error);
      showErrorModal('Error adding new user: Please check the data and retry again');
      $('#updateUserSubmit').prop('disabled', false);
    }
  },
//DONE
  addType: async function(form) {
    $('#addTypeSubmit').prop('disabled', true);
    const caseTypeID = document.getElementById('caseTypeID').value;
    const description = document.getElementById('description').value;
    const category = document.getElementById('category').value;
    const level = document.getElementById('level').value;

    console.log('Form submitted:', { caseTypeID, description, category, level });

    try {
      const instance = await App.contracts.Case.deployed();
      const result = await instance.addType(caseTypeID,description,category,level, { from: App.account, gas: 500000 });
      console.log('Transaction Hash:', result.tx);
      web3.eth.getTransactionReceipt(result.tx, function(error, receipt) {
        if (error) {
          console.error('Error retrieving transaction receipt:', error);
          showErrorModal('Error retrieving transaction receipt: ' + error.message);
        } else {
          console.log('Transaction Receipt:', receipt);
          if (receipt && receipt.status) {
            console.log('Transaction was successful and data was added');
            showSuccessModal('Transaction was successful and data was added', form);
          } else {
            console.log('Transaction failed or data was not added');
            showErrorModal('Transaction failed or data was not added');
          }
        }
        $('#addTypeSubmit').prop('disabled', false);
      });
    }catch (error) {
      console.error('Error adding type:', error); 
          showErrorModal('Error adding type: Please check the data and retry again');
      $('#addTypeSubmit').prop('disabled', false);
  }
  },
//DONE
  viewType: async function() {
    $('#searchCaseTypeButton').prop('disabled', true); 
    const caseTypeID = document.getElementById('caseTypeID').value;
  
    try {
      const instance = await App.contracts.Case.deployed(); 
      const result = await instance.getType(caseTypeID, { from: App.account });
      if (result && result[0] && result[1] && result[2]) {
        userTableBody.innerHTML = `
        <tr>
          <td class="td1">${caseTypeID}</td>
          <td class="td2">${result[0]}</td>
          <td class="td3">Level 0${result[1].toString()}</td>
          <td class="td4">${result[2]}</td>
        </tr>
      `;
      document.getElementById('typeData').style.display = 'block';
      } else {
        console.log('Case type with ID', caseTypeID, 'not found');
        showErrorModal('Case type with ID ' + caseTypeID + ' not found');
      }
    } catch (error) {
      console.error('Error retrieving user data:', error);
      if (error.data.message.includes('found')) {
          showErrorModal('Case type with ID ' + caseTypeID + ' not found');
      } else {
          showErrorModal('Error retrieving user data: ' + error.message);
      }
  }  finally {
      $('#searchCaseTypeButton').prop('disabled', false); 
    }
  },
//DONE
  addCase: async function(form) {
      $('#addCaseSubmit').prop('disabled', true);
      const caseTitle = document.getElementById('caseTitle').value;
      const caseID = document.getElementById('caseID').value;
      const caseTypeID = document.getElementById('caseTypeID').value;
      const file = document.getElementById('captureData').files[0];

      console.log(caseTitle);
      console.log(caseID);
      console.log(caseTypeID);
      console.log(file);
    try {
      const uint8Array = await App.convertFile(file);
      console.log(uint8Array);

      const ipfsPath = await App.uploadToIPFS(uint8Array);
      console.log(ipfsPath);

      const instance = await App.contracts.Case.deployed();
      const result = await instance.addCase(caseTitle, caseID, caseTypeID, ipfsPath, { from: App.account, gas: 500000 });
      console.log('Transaction Hash:', result.tx);

      web3.eth.getTransactionReceipt(result.tx, function(error, receipt) {
        if (error) {
          console.error('Error retrieving transaction receipt:', error);
          showErrorModal('Error retrieving transaction receipt: ' + error.message);
        } else {
          console.log('Transaction Receipt:', receipt);
          if (receipt && receipt.status) {
            console.log('Case added successfully');
            showSuccessModal('Case added successfully', form);
          } else {
            console.log('Transaction failed or case was not added');
            showErrorModal('Transaction failed or case was not added');
          }
        }
        $('#addCaseSubmit').prop('disabled', false);
      });
    } catch (error) {
      console.error('Error adding case:', error);
      showErrorModal('Error adding case: Please check the data and retry again');
      $('#addCaseSubmit').prop('disabled', false);
    }
    
  },
//DONE
  viewCase: async function() {
    $('#searchCaseButton').prop('disabled', true); 
    const caseID = document.getElementById('caseID').value;
  
    try {
      const instance = await App.contracts.Case.deployed(); 
      const result = await instance.getCase(caseID, { from: App.account });
  
      if (result && result[0] && result[1] && result[2] && result[3] && result[4]) {
        let Status;
            if (result[4] == 1) {
                Status = "Open";
            } else if (result[4] == 0) {
                Status = "Close";
            }

        userTableBody.innerHTML = `
        <tr>
          <td>${caseID}</td>
          <td>${result[0]}</td>
          <td>${result[1]}</td>
          <td>${result[3]}</td>
          <td>${Status}</td>
          <td>
          <a href="#" onclick="App.downloadReport('${result[2]}')">Download</a>
          </td>
        </tr>
      `;
      document.getElementById('caseData').style.display = 'block';
      } else {
        console.log('Case with ID', caseID, 'not found');
        showErrorModal('Case with ID ' + caseID + ' not found');
      }
    } catch (error) {
      console.error('Error retrieving user data:', error);
      if (error.data.message.includes('found')) {
          showErrorModal('Case with ID ' + caseID + ' not found');
      } else {
          showErrorModal('Error retrieving user data: ' + error.message);
      }
  }  finally {
      $('#searchCaseButton').prop('disabled', false); 
    }
  },
//DONE
  searchCaseForUpdate: async function() {
    $('#searchCaseForUpdateButton').prop('disabled', true);
    const ID = document.getElementById('ID').value;
    
    try {
      const instance = await App.contracts.Case.deployed();
      const result = await instance.getCase(ID, { from: App.account });
      
      if (result && result[0] && result[1] && result[2] && result[3]) {

        document.getElementById('titleValue').value = result[0];
        document.getElementById('statusValue').value = result[4];
        document.getElementById('caseData').style.display = 'block'; 
      } else {
        console.log('Case with ID', ID, 'not found');
        showErrorModal('Case with ID ' + ID + ' not found');
      }
  
    } catch (error) {
      console.error('Error retrieving Case data:', error);
      if (error.data.message.includes('Case')) {
        showErrorModal('User with ID ' + ID + ' not found');
      } else {
        showErrorModal('Error retrieving user data: ' + error.message);
      }
    } finally {
      $('#searchcaseForUpdateButton').prop('disabled', false);
    }
  },
//DONE
  updateCase: async function(form) {
    $('updateCaseSubmit').prop('disabled',true);
    const caseID = document.getElementById('ID').value;
    const status = document.getElementById('statusValue').value;
    console.log(caseID,status);

    try{
      const instance = await  App.contracts.Case.deployed();
      const result = await instance.updateCaseStatus(caseID,status, { from: App.account, gas: 500000 })
      console.log('Transaction Hash:', result.tx);

      web3.eth.getTransactionReceipt(result.tx, function(error, receipt) {
        if (error) {
          console.error('Error retrieving transaction receipt:', error);
          showErrorModal('Error retrieving transaction receipt: ' + error.message);
        } else {
          console.log('Transaction Receipt:', receipt);
          if (receipt && receipt.status) {
            console.log('Case updated successfully');
            showSuccessModal('Case updated successfully', form);
          } else {
            console.log('Transaction failed or case was not added');
            showErrorModal('Transaction failed or case was not added');
          }
        }
        $('updateCaseSubmit').prop('disabled',false);
      });
    }catch (error){
      console.error('Error updating case:', error);
      showErrorModal('Error updating case: Please check the data and retry again');
      $('updateCaseSubmit').prop('disabled',false);
    }
    
  },
//DONE
  addEvidence: async function(form) {
    $('#addEvidenceSubmit').prop('disabled',true);
    console.log('button disable');
    const caseID = document.getElementById('caseID').value;
    const evidenceID = document.getElementById('evidenceID').value;
    const evidenceType = document.getElementById('evidenceType').value;
    const file = document.getElementById('captureData').files[0]

    console.log(caseID,
      evidenceID,
      evidenceType,
      file);

      try {
        const uint8Array = await App.convertFile(file);
        console.log(uint8Array);
  
        const ipfsPath = await App.uploadToIPFS(uint8Array);
        console.log(ipfsPath);
  
        const instance = await App.contracts.Case.deployed();
        const result = await instance.addEvidence(caseID, evidenceID, evidenceType, ipfsPath, { from: App.account, gas: 500000 });
        console.log('Transaction Hash:', result.tx);
  
        web3.eth.getTransactionReceipt(result.tx, function(error, receipt) {
          if (error) {
            console.error('Error retrieving transaction receipt:', error);
            showErrorModal('Error retrieving transaction receipt: ' + error.message);
          } else {
            console.log('Transaction Receipt:', receipt);
            if (receipt && receipt.status) {
              console.log('Evidence added successfully');
              showSuccessModal('Evidence added successfully', form);
            } else {
              console.log('Transaction failed or evidence was not added');
              showErrorModal('Transaction failed or evidence was not added');
            }
          }
          $('#addEvidenceSubmit').prop('disabled', false);
        });
      } catch (error) {
        console.error('Error adding evidence:', error);
        showErrorModal('Error adding evidence: Please check the data and retry again');
        $('#addEvidenceSubmit').prop('disabled', false);
      }

  },
//DONE
  viewEvidence: async function() {
    $('#searchEvidenceButton').prop('disabled', true); 
    const caseID = document.getElementById('caseID').value;
    const evidenceID = document.getElementById('evidenceID').value;
  
    try {
      const instance = await App.contracts.Case.deployed(); 
      const result = await instance.getEvidence(caseID,evidenceID, { from: App.account });
      
  
      if (result && result[0] && result[1] && result[2] && result[3]) {
        let Status;
            if (result[3] == 1) {
                Status = "Open";
            } else if (result[3] == 0) {
                Status = "Close";
            }

        userTableBody.innerHTML = `
        <tr>
          <td>${caseID}</td>
          <td>${evidenceID}</td>
          <td>${result[0]}</td>
          <td>${result[2]}</td>
          <td>${Status}</td>
          <td>
          <a href="#" onclick="App.downloadReport('${result[1]}')">Download</a>
          </td>
        </tr>
      `;
      document.getElementById('evidenceData').style.display = 'block';
      } else {
        console.log('Evidence with ID', caseID, 'not found');
        showErrorModal('Evidence with ID ' + caseID + ' not found');
      }
    } catch (error) {
      console.error('Error retrieving user data:', error);
      if (error.data.message.includes('found')) {
          showErrorModal('Evidence with ID ' + caseID + ' not found');
      } else {
          showErrorModal('Error retrieving user data: ' + error.message);
      }
  }  finally {
      $('#searchEvidenceButton').prop('disabled', false); 
    }
  },
//DONE
  searchEvidenceForUpdate: async function() {
    $('#searchEvidenceForUpdate').prop('disabled', true);
    const caseID = document.getElementById('caseID').value;
    const evidenceID = document.getElementById('evidenceID').value;
    
    try {
      const instance = await App.contracts.Case.deployed();
      const result = await instance.getEvidence(caseID,evidenceID, { from: App.account });
      
      if (result && result[0] && result[1] && result[2] && result[3]) {

        document.getElementById('caseIdValue').value = caseID;
        document.getElementById('evidenceTypeValue').value = result[0];
        document.getElementById('statusValue').value = result[3];
        document.getElementById('evidenceData').style.display = 'block'; 
      } else {
        console.log('Evidence with ID', evidenceID, 'not found');
        showErrorModal('Evidence with ID ' + evidenceID + ' not found');
      }
  
    } catch (error) {
      console.error('Error retrieving Evidence data:', error);
      if (error.data.message.includes('Evidence')) {
        showErrorModal('Evidence with ID ' + evidenceID + ' not found');
      } else {
        showErrorModal('Error retrieving Evidence data: ' + error.message);
      }
    } finally {
      $('#searchEvidenceForUpdate').prop('disabled', false);
    }
  },
//DONE
  updateEvidence: async function(form) {

    $('updateEvidenceSubmit').prop('disabled',true);
    const caseID = document.getElementById('caseID').value;
    const evidenceID = document.getElementById('evidenceID').value;
    const status = document.getElementById('statusValue').value;

    try{
      const instance = await  App.contracts.Case.deployed();
      const result = await instance.updateEvidenceStatus(caseID,evidenceID,status, { from: App.account, gas: 500000 })
      console.log('Transaction Hash:', result.tx);

      web3.eth.getTransactionReceipt(result.tx, function(error, receipt) {
        if (error) {
          console.error('Error retrieving transaction receipt:', error);
          showErrorModal('Error retrieving transaction receipt: ' + error.message);
        } else {
          console.log('Transaction Receipt:', receipt);
          if (receipt && receipt.status) {
            console.log('Evidence updated successfully');
            showSuccessModal('Evidence updated successfully', form);
          } else {
            console.log('Transaction failed or evidence was not added');
            showErrorModal('Transaction failed or evidence was not added');
          }
        }
        $('updateEvidenceSubmit').prop('disabled',false);
      });
    }catch (error){
      console.error('Error updating evidence:', error);
      showErrorModal('Error updating evidence: Please check the data and retry again');
      $('updateEvidenceSubmit').prop('disabled',false);
    }
    
  },
//DONE
  downloadReport: async function(reportHash) {
    try {
      const chunks = [];
      for await (const chunk of ipfs.cat(reportHash)) {
        chunks.push(chunk);
      }
      const content = new Blob(chunks);
      const reader = new FileReader();

      reader.onload = function(e) {
        const downloadUrl = e.target.result;
        // Trigger the download
        window.location.href = downloadUrl;
      };

      reader.onerror = function(e) {
        console.error('Error reading Blob:', e);
        showErrorModal('An error occurred while downloading the report.');
      };

      reader.readAsDataURL(content);
    } catch (error) {
      console.error('Error downloading report from IPFS:', error);
      showErrorModal('An error occurred while downloading the report.');
    }
  },
//DONE
  convertFile: function(file) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.readAsArrayBuffer(file);
      reader.onloadend = () => {
        const arrayBuffer = reader.result;
        const uint8Array = new Uint8Array(arrayBuffer);
        resolve(uint8Array);
      };
      reader.onerror = (error) => {
        reject(error);
      };
    });
  },
//DONE
  uploadToIPFS: async function(uint8Array) {
    try {
      const result = await ipfs.add(uint8Array);
      console.log('IPFS hash = ' + result.path);
      return result.path;
    } catch (error) {
      console.error("Error uploading to IPFS:", error);
      throw error;
    }
  }

};

function showSuccessModal(message,form) {
  $('#successMassageModalLabel').text('SUCCESSFUL');
  $('#successMessage').text(message);
  $('#successMassageModal').modal('show');
  setTimeout(function() {
    $('#successMassageModal').modal('hide');
    App.resetForm(form);
  }, 2000);
}

function showErrorModal(message) {
  $('#errorMassageModalLabel').text('ERROR');
  $('#errorMessage').text(message);
  $('#errorMassageModal').modal('show');
}

function rotateLogo() {
  const logo = document.getElementById('logo').querySelector('img');
  logo.classList.add('rotated'); 
  setTimeout(() => {
    logo.classList.remove('rotated'); 
  }, 1000);
}
$(document).ready(function() {
  App.init();
});

