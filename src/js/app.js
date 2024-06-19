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
      } catch (error) {
        console.error("User denied account access");
      }
    } else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
      web3 = new Web3(window.web3.currentProvider);
      console.log("Connected to Ethereum via window.web3");
    } else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
      web3 = new Web3(App.web3Provider);
      console.log("Connected to Ethereum via localhost:7545");
    }
    return App.initContract();
  },

  initContract: function() {
    console.log("Initializing contract...");
    $.getJSON('SecureEvidence.json', function(data) {
      console.log("Contract data loaded");
      var SecureEvidenceData = data;
      App.contracts.SecureEvidence = TruffleContract(SecureEvidenceData);
      App.contracts.SecureEvidence.setProvider(App.web3Provider);

      App.contracts.SecureEvidence.deployed().then(function(instance) {
        console.log("Contract deployed at address:", instance.address);
        return App.render();
      }).catch(function(err) {
        console.error("Error deploying contract:", err);
      });
    }).fail(function(jqxhr, textStatus, error) {
      console.error("Failed to load contract JSON:", textStatus, error);
    });
  },

  render: function() {
    console.log("Rendering App...");
    var loader = $("#loader");
    var content = $("#content");
    var pageContent = $("#page-content");

    loader.show();
    content.hide();
    pageContent.hide();

    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        console.log("Account:", App.account);
        if (App.account) {
          $("#accountAddress").html("Your Account: " + App.account);
          if (localStorage.getItem('isLoggedIn') === 'true') {
            $("#loader").hide();
            $("#content").hide();
            $("#page-content").show();
            
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

    $("#submitUsername").click(function() {
      var username = $("#username").val();
      if (username !== "") {
        App.login(username);
      } else {
        $("#loginMessage").html("Please enter username");
      }
    });
    
    $("#logoutButton").click(function() {
      App.logout();
    });

    $("#addTypeForm").submit(function(event) {
      event.preventDefault(); // Prevent the form from refreshing the page
      App.addType();
    });

    $('#errorMassageModal').on('click', '.error-button', function() {
      $('#errorMassageModal').modal('hide');
    });

    $("#resetButton").click(function(event) {
      event.preventDefault();
      App.resetForm();
    });

    $('#dashboard').click(function(event) {
      window.location.href = 'dashboard.html'; 
    });

    $('#addCaseTypeLink').click(function(event) {
        window.location.href = 'addType.html'; 
    });
    document.addEventListener('mousemove', App.resetLogoutTimer);
    document.addEventListener('keydown', App.resetLogoutTimer);
    document.addEventListener('click', App.resetLogoutTimer);
  },

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

  login: function() {
    var username = $("#username").val();
    if (username === "") {
      $("#loginMessage").html("Please enter username");
      return;
    }
    App.contracts.SecureEvidence.deployed().then(function(instance) {
      return instance.login(username, { from: App.account });
    }).then(function(result) {
      $("#loginMessage").html(result);
      if (result.includes("Welcome")) {
        console.log("Super Admin logged ");
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

  logout: function() {
    localStorage.setItem('isLoggedIn', 'false');
    $("#page-content").hide();
    $("#content").show();
    $("#loginMessage").html("You have logged out.");
    window.location.href = "index.html";
    if (App.logoutTimeout) {
      clearTimeout(App.logoutTimeout); 
    }
  },

  resetLogoutTimer: function() {
    if (App.logoutTimeout) {
      clearTimeout(App.logoutTimeout); 
    }
    App.logoutTimeout = setTimeout(App.logout, App.logoutTimeLimit); 
  },

  resetForm: function() { 
    rotateLogo();
    $('#addTypeForm')[0].reset();
  },

  addType: async function() {
    $('#addTypeSubmit').prop('disabled', true);
    const caseType = document.getElementById('caseType').value;
    const description = document.getElementById('description').value;
    const category = document.getElementById('category').value;
    const level = document.getElementById('level').value;

    console.log('Form submitted:', { caseType, description, category, level });

    try {
      const instance = await App.contracts.SecureEvidence.deployed();
      const result = await instance.addType(caseType, description, category, level, { from: App.account, gas: 500000 });
      console.log('Transaction Hash:', result.tx);

      web3.eth.getTransactionReceipt(result.tx, function(error, receipt) {
        if (error) {
          console.error('Error retrieving transaction receipt:', error);
          showErrorModal('Error retrieving transaction receipt: ' + error.message);
        } else {
          console.log('Transaction Receipt:', receipt);
          if (receipt && receipt.status) {
            console.log('Transaction was successful and data was added');
            showSuccessModal('Transaction was successful and data was added');
          } else {
            console.log('Transaction failed or data was not added');
            showErrorModal('Transaction failed or data was not added');
          }
        }
        $('#addTypeSubmit').prop('disabled', false);
      });
    } catch (error) {
      console.error('Error adding type:', error);
      showErrorModal('Error adding type: Please check the data and retry again');
      $('#addTypeSubmit').prop('disabled', false);
    }
  }
  
};

function showSuccessModal(message) {
  $('#successMassageModalLabel').text('SUCCESSFUL');
  $('#successMessage').text(message);
  $('#successMassageModal').modal('show');
  setTimeout(function() {
    $('#successMassageModal').modal('hide');
    App.resetForm();
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


