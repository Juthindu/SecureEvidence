let web3;
let imageStore;
let ipfs;

window.addEventListener('load', async () => {
    console.log("Initializing............");
    if (window.ethereum) {
        web3 = new Web3(window.ethereum);

        // Prompt user to connect their MetaMask account
        try {
            await ethereum.request({ method: 'eth_requestAccounts' });
            displayAccount();
            ethereum.on('disconnect', (error) => {
                if (error) {
                    console.error("MetaMask disconnected due to error:", error);
                } else {
                    console.log("MetaMask disconnected");
                    clearAccount();
                }
            });
        } catch (error) {
            console.error("User denied account access");
            clearAccount();
        }
    } else {
        console.error("Non-Ethereum browser detected. You should consider trying MetaMask!");
        clearAccount();
    }

    // Initialize IPFS client
    ipfs = window.IpfsHttpClient.create({ host: 'localhost', port: '5001', protocol: 'http' });

    // Function to display user account
    function displayAccount() {
        web3.eth.getAccounts().then(accounts => {
            if (accounts.length > 0) {
                document.getElementById('account').innerText = `Connected Account: ${accounts[0]}`;
                setupForms();
            } else {
                clearAccount();
            }
        }).catch(err => {
            console.error("Error fetching accounts:", err);
            clearAccount();
        });
    }

    // Function to clear account display
    function clearAccount() {
        document.getElementById('account').innerText = "Please connect your MetaMask account";
    }

    // Setup forms and event listeners
    function setupForms() {
        document.getElementById('uploadForm').style.display = 'block';
        document.getElementById('fetchImageForm').addEventListener('submit', getImageHandler);
        document.getElementById('imageForm').addEventListener('submit', uploadImageHandler);
    }

    // Function to handle image upload
    async function uploadImageHandler(event) {
        console.log('submit button click');
        event.preventDefault();
        const name = document.getElementById('imageName').value;
        const file = document.getElementById('imageFile').files[0];

        if (!name || !file) {
            alert("Please enter image name and select a file");
            return;
        }

        const reader = new FileReader();
        reader.readAsArrayBuffer(file);
        reader.onloadend = async () => {
            const arrayBuffer = reader.result;
            const uint8Array = new Uint8Array(arrayBuffer);

            try {
                const ipfsHash = await uploadToIPFS(uint8Array);
                await saveToBlockchain(name, ipfsHash);
            } catch (error) {
                console.error("Error uploading image and saving to blockchain:", error);
                alert("Error uploading image and saving to blockchain. Please try again.");
            }
        };
    }

    // Function to handle image retrieval
    async function getImageHandler(event) {
        event.preventDefault();
        console.log('get image button click ');
        const imageName = document.getElementById('getImageName').value.trim();
        if (imageName === '') {
            alert("Please enter an image name");
            return;
        }

        try {
            const ipfsHash = await getImageFromBlockchain(imageName);
            if (ipfsHash) {
                console.log('return hash',ipfsHash);
                displayImageFromIPFS(ipfsHash);
            } else {
                alert("Image not found");
            }
        } catch (error) {
            console.error("Error retrieving image:", error);
            alert("Error retrieving image. Please try again.");
        }
    }

    // Function to upload image to IPFS
    async function uploadToIPFS(uint8Array) {
        try {
            const result = await ipfs.add(uint8Array);
            console.log('ipfs hash = '+result.path);
            return result.path;
        } catch (error) {
            console.error("Error uploading to IPFS:", error);
            throw error;
        }
    }

    // Function to save image details to blockchain
    async function saveToBlockchain(name, ipfsHash) {
        try {
            const networkId = await web3.eth.net.getId();
            const response = await fetch('ImageStore.json');
            const artifact = await response.json();
            const networkData = artifact.networks[networkId];

            if (networkData) {
                imageStore = new web3.eth.Contract(
                    artifact.abi,
                    networkData.address
                );

                // Call uploadImage function from smart contract
                await imageStore.methods.uploadImage(name, ipfsHash).send({ from: web3.currentProvider.selectedAddress });
                alert("Image uploaded and saved to blockchain successfully!");
            } else {
                console.error("Smart contract not deployed to detected network.");
            }
        } catch (error) {
            console.error("Error saving to blockchain:", error);
            throw error;
        }
    }

    // Function to retrieve IPFS hash from blockchain
    async function getImageFromBlockchain(name) {
        console.log('getimage',name);
        try {
            const networkId = await web3.eth.net.getId();
            const response = await fetch('ImageStore.json');
            const artifact = await response.json();
            const networkData = artifact.networks[networkId];

            if (networkData) {
                imageStore = new web3.eth.Contract(
                    artifact.abi,
                    networkData.address
                );
                console.log('....................',await imageStore.methods.getImagePath(name).call());
                // Call getImagePath function from smart contract
                return await imageStore.methods.getImagePath(name).call();
            } else {
                console.error("Smart contract not deployed to detected network.");
            }
        } catch (error) {
            console.error("Error fetching image path:", error);
            throw error;
        }
    }

    // Function to display image from IPFS
    async function displayImageFromIPFS(ipfsHash) {
        console.log('IPFS Hash:', ipfsHash);
        try {
            // Fetch the content from IPFS
            const chunks = [];
            for await (const chunk of ipfs.cat(ipfsHash)) {
                chunks.push(chunk);
            }
            const content = new Blob(chunks);
    
            // Create URL for the blob content
            const imageUrl = URL.createObjectURL(content);
    
            // Display the image
            document.getElementById('displayedImage').src = imageUrl;
            document.getElementById('imageDisplay').style.display = 'block';
        } catch (error) {
            console.error("Error displaying image from IPFS:", error);
            throw error;
        }
    }
    
});
