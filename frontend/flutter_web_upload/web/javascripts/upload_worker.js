self.addEventListener('message', async (event) => {
  console.log(`message recieved: ${event.data.uri}`);
  var file = event.data.file;
  var url = event.data.uri;
  uploadFile(file, url);
});

function uploadFile(file, url) {
  var xhr = new XMLHttpRequest();
  var formdata = new FormData();
  var uploadPercent;

  formdata.append('file', file);

  xhr.upload.addEventListener('progress', function (e) {
    //console.log('uploading...');
    //Use this if you want to have a progress bar
    if (e.lengthComputable) {
      uploadPercent = Math.floor((e.loaded / e.total) * 100);
      //console.log(`uploaded: ${uploadPercent}`)
      postMessage([true, uploadPercent]);
    }
  }, false);
  xhr.onreadystatechange = function () {
    if (xhr.readyState == XMLHttpRequest.DONE) {
      postMessage([false, JSON.parse(xhr.response)]);

    }
  }
  xhr.onerror = function () {
    // only triggers if the request couldn't be made at all
    postMessage([false, "Request failed"]);
  };

  xhr.open('POST', url, true);

  xhr.send(formdata);
}