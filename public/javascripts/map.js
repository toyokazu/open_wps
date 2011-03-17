// initialize by specifying elements and map image path
function Map(image_path, elem_canvas, max_x, max_y, curr_x, curr_y, elem_curr_x, elem_curr_y, elem_step_x, elem_step_y) {
  this.image = new Image();
  this.image.src = image_path;
  this.image_preloaded = false;
  this.elem_canvas = elem_canvas;
  this.max_x = max_x;
  this.max_y = max_y;
  this.curr_x = curr_x;
  this.curr_y = curr_y;
  this.elem_curr_x = elem_curr_x;
  this.elem_curr_y = elem_curr_y;
  this.elem_step_x = elem_step_x;
  this.elem_step_y = elem_step_y;
  this.elem_canvas.width = this.max_x;
  this.elem_canvas.height = this.max_y;
  this.ctx = this.elem_canvas.getContext('2d');
};

Map.prototype = {
  // update current position element values
  updateCurrentPositionElements: function() {
    this.elem_curr_x.value = this.curr_x;
    this.elem_curr_y.value = this.curr_y;
  },

  draw: function(x, y) {
    // display by default order (destination displayed as a lower layer)
    // use comment outed line when you want destination as an upper layer destination
    //ctx.globalCompositeOperation = 'destination-over';
    this.ctx.clearRect(0, 0, this.max_x, this.max_y); // clear canvas

    this.ctx.fillStyle = 'rgba(0,0,0,0.4)';
    // semitransparent blue
    this.ctx.strokeStyle = 'rgba(0,153,255,0.4)';
    this.ctx.save();
    //ctx.translate(150,150);

    // display background image
    this.image.onload = function() {
      this.ctx.drawImage(this.image, 0, 0);
      this.image_preloaded = true;
    }.bind(this);
    // if this.image is already loaded
    if (this.image_preloaded) {
      this.ctx.drawImage(this.image, 0, 0);
    }
    // display current position
    if (!Object.isUndefined(this.curr_x) && !Object.isUndefined(this.curr_y)) {
      // red
      this.ctx.strokeStyle = 'rgba(255,0,0,1)';
      this.ctx.beginPath();
      this.ctx.arc(this.curr_x, this.curr_y, 1, 0, Math.PI*2, false);
      this.ctx.closePath();
      this.ctx.stroke();
      this.updateCurrentPositionElements();
    }
    // display assist line
    if (!Object.isUndefined(x) && !Object.isUndefined(y)) {
      this.ctx.restore();
      this.ctx.lineWidth = 1;
      this.ctx.beginPath();
      this.ctx.moveTo(x, 0);
      this.ctx.lineTo(x, this.max_y);
      this.ctx.moveTo(0, y);
      this.ctx.lineTo(this.max_x, y);
      this.ctx.closePath();
      this.ctx.stroke();
    }
  },

  drawWithLine: function(e) {
    var position = this.getPosition(e);
    this.draw(position.x, position.y);
  },

  drawWithoutLine: function(e) {
    this.draw();
  },

  drawStatic: function(additionalDraw) {
    this.image.onload = function() {
      this.ctx.drawImage(this.image, 0, 0);
      this.image_preloaded = true;
      additionalDraw();
    }.bind(this);
  },

  drawWifiLog: function(x, y, rssi) {
    //this.ctx.strokeStyle = 'rgba(0,255,0,1)';
    this.ctx.strokeStyle = this.wifiLogColor(rssi);
    this.ctx.beginPath();
    this.ctx.arc(x, y, 1, 0, Math.PI*2, false);
    this.ctx.closePath();
    this.ctx.stroke();
  },

  wifiLogColor: function(rssi) {
    var red = 0, green = 0, blue = 0;
    var x = 100 + rssi;
    var rgb = '';

    if (x >= 0 && x <= 32) {
      blue = Math.floor(-8 * x + 256);
      green = 0;
      //green = Math.floor(8 * x);
      red = Math.floor(8 * x);
      //red = 0;
    } else {
      red = Math.floor(-8 * x + 512);
      //red = 0;
      green = 0;
      //green = Math.floor(-8 * x + 512);
      blue = Math.floor(8 * x - 256);
    }
    rgb = 'rgba(' + red + ',' + green + ',' + blue + ',1)';
    //alert(rgb);
    return rgb;
  },

  //
  drawWifiAccessPoint: function(x, y) {
    this.ctx.strokeStyle = 'rgba(0,255,0,1)';
    this.ctx.beginPath();
    this.ctx.arc(x, y, 1, 0, Math.PI*2, false);
    this.ctx.closePath();
    this.ctx.stroke();
  },

  //
  drawMovementLog: function(x, y) {
    this.ctx.strokeStyle = 'rgba(0,0,255,1)';
    this.ctx.beginPath();
    this.ctx.arc(x, y, 1, 0, Math.PI*2, false);
    this.ctx.closePath();
    this.ctx.stroke();
  },

  //
  getPosition: function(e) {
    var x = Event.pointerX(e);
    var y = Event.pointerY(e);
    var item = Event.element(e);
    var top = 0, left = 0; 
    if (!e) { e = window.event; } 
    var myTarget = e.currentTarget; 
    if (!myTarget) { 
      myTarget = e.srcElement; 
    } 
    else if (myTarget == "undefined") { 
      myTarget = e.srcElement; 
    } 
    while(myTarget!= document.body) { 
      top += myTarget.offsetTop; 
      left += myTarget.offsetLeft; 
      myTarget = myTarget.offsetParent; 
    }
    return {x: (x - left), y: (y - top)};
  },
  
  // set current position mark where a user clicks
  setCurrentPosition: function(e) {
    var position = this.getPosition(e);
    this.curr_x = position.x;
    this.curr_y = position.y;
    this.draw(position.x, position.y);
  },

  // reflect current position element value to the map
  changeValueX: function(e) {
    this.curr_x = Event.element(e).value;
    this.draw();
  },

  // reflect current position element value to the map
  changeValueY: function(e) {
    this.curr_y = Event.element(e).value;
    this.draw();
  },

  //
  moveUp: function(e) {
    var step_y = parseInt(this.elem_step_y.value);
    this.curr_y = this.curr_y - step_y;
    this.draw();
  },

  //
  moveLeft: function(e) {
    var step_x = parseInt(this.elem_step_x.value);
    this.curr_x = this.curr_x - step_x;
    this.draw();
  },

  //
  moveRight: function(e) {
    var step_x = parseInt(this.elem_step_x.value);
    this.curr_x = this.curr_x + step_x;
    this.draw();
  },

  //
  moveDown: function(e) {
    var step_y = parseInt(this.elem_step_y.value);
    this.curr_y = this.curr_y + step_y;
    this.draw();
  },

};
