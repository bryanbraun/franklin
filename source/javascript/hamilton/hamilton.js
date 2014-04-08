function toggleToc(evt) {
  evt.preventDefault();
  var toc = document.getElementById('toc-nav');
  if (toc.style.display !== 'none') {
    toc.style.display = 'none';
  } else {
    toc.style.display = '';
  }
}

var el = document.getElementById('toc-title');
el.addEventListener('click', toggleToc);