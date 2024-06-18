function rotateLogo() {
    // Select the img element inside the #logo div
    const logo = document.getElementById('logo').querySelector('img');
    logo.classList.add('rotated'); 
    setTimeout(() => {
      logo.classList.remove('rotated'); 
    }, 1000);
  }