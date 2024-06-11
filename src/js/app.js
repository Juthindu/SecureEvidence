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
    var sidebar = $("#sidebar");
    var dashboard =$("#dashboard");
    var loginLogo =$("#loginLogo");

    loginLogo.show();
    loader.show();
    content.hide();
    sidebar.hide();
    dashboard.hide();

    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        console.log("Account:", App.account);
        if (App.account) {
          $("#accountAddress").html("Your Account: " + App.account);
          if (localStorage.getItem('isLoggedIn') === 'true') {
            $("#loginLogo").hide();
            $("#loader").hide();
            $("#content").hide();
            $("#sidebar").show();
            $("#dashboard").show();
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
        $("#loginLogo").hide();
        $("#content").hide();
        $("#sidebar").show();
        $("#dashboard").show();
        localStorage.setItem('isLoggedIn', 'true');
        //window.location.href = "dashboard.html";
        window.location.href = "test.html";
      }
    }).catch(function(error) {
      console.error(error);
      $("#loginMessage").html(error);
    });
  },
  logout: function() {
    localStorage.setItem('isLoggedIn', 'false');
    $("#sidebar").hide();
    $("#dashboard").hide();
    $("#content").show();
    $("#loginLogo").show();
    $("#loginMessage").html("You have logged out.");
    window.location.href = "index.html";
    if (App.logoutTimeout) {
      clearTimeout(App.logoutTimeout); // Clear the logout timeout when logging out
    }
  },

  resetLogoutTimer: function() {
    if (App.logoutTimeout) {
      clearTimeout(App.logoutTimeout); // Clear existing timeout
    }
    App.logoutTimeout = setTimeout(App.logout, App.logoutTimeLimit); // Set new timeout
  },
};

$(document).ready(function() {
  App.init();
});


// sidebar component


$(document).ready(function () {
  var trigger = $('.hamburger'),
      overlay = $('.overlay'),
     isClosed = false;

    trigger.click(function () {
      hamburger_cross();      
    });

    function hamburger_cross() {

      if (isClosed == true) {          
        overlay.hide();
        trigger.removeClass('is-open');
        trigger.addClass('is-closed');
        isClosed = false;
      } else {   
        overlay.show();
        trigger.removeClass('is-closed');
        trigger.addClass('is-open');
        isClosed = true;
      }
  }
  
  $('[data-toggle="offcanvas"]').click(function () {
        $('#wrapper').toggleClass('toggled');
  });  
});