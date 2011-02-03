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
};

Map.prototype = {
  // update current position element values
  updateCurrentPositionElements: function() {
    this.elem_curr_x.value = this.curr_x;
    this.elem_curr_y.value = this.curr_y;
  },

  draw: function(x, y) {
    var ctx = this.elem_canvas.getContext('2d');
    // デフォルトの順番で表示 (destination が下)
    // destination を上にする場合は以下のコメントをはずす
    //ctx.globalCompositeOperation = 'destination-over';
    ctx.clearRect(0, 0, this.max_x, this.max_y); // canvas を消去

    ctx.fillStyle = 'rgba(0,0,0,0.4)';
    // 半透明の青色
    ctx.strokeStyle = 'rgba(0,153,255,0.4)';
    ctx.save();
    //ctx.translate(150,150);

    // 背景画像を表示
    this.image.onload = function() {
      ctx.drawImage(this.image, 0, 0);
      this.image_preloaded = true;
    }.bind(this);
    // すでに this.image がロードされている場合
    if (this.image_preloaded) {
      ctx.drawImage(this.image, 0, 0);
    }
    // 現在位置を表示
    if (!Object.isUndefined(this.curr_x) && !Object.isUndefined(this.curr_y)) {
      // 赤色
      ctx.strokeStyle = 'rgba(255,0,0,1)';
      ctx.beginPath();
      ctx.arc(this.curr_x, this.curr_y, 1, 0, Math.PI*2, false);
      ctx.closePath();
      ctx.stroke();
      this.updateCurrentPositionElements();
    }
    // 補助線を表示
    if (!Object.isUndefined(x) && !Object.isUndefined(y)) {
      ctx.restore();
      ctx.lineWidth = 1;
      ctx.beginPath();
      ctx.moveTo(x, 0);
      ctx.lineTo(x, this.max_y);
      ctx.moveTo(0, y);
      ctx.lineTo(this.max_x, y);
      ctx.closePath();
      ctx.stroke();
    }
  },

  drawWithLine: function(e) {
    var position = this.getPosition(e);
    this.draw(position.x, position.y);
  },

  drawWithoutLine: function(e) {
    this.draw();
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
