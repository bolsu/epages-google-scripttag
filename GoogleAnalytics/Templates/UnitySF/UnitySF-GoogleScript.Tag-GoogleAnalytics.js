console.log('GoogleScript Tag: Google Analytics');

window.dataLayer = window.dataLayer || [];
if ( typeof gtag !== undefined ) {
  console.log('GoogleScript Tag: gtag defined!');
} else {
  console.log('GoogleScript Tag: gtag undefined, defining it!');
  function gtag() { dataLayer.push(arguments); }
}
