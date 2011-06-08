Raphael.fn.connection = function (obj1, obj2, line, bg) {
    if (obj1.line && obj1.from && obj1.to) {
        line = obj1;
        obj1 = line.from;
        obj2 = line.to;
    }
    var bb1 = obj1.getBBox(),
        bb2 = obj2.getBBox(),
        p = [{x: bb1.x + bb1.width / 2, y: bb1.y - 1},
        {x: bb1.x + bb1.width / 2, y: bb1.y + bb1.height + 1},
        {x: bb1.x - 1, y: bb1.y + bb1.height / 2},
        {x: bb1.x + bb1.width + 1, y: bb1.y + bb1.height / 2},
        {x: bb2.x + bb2.width / 2, y: bb2.y - 1},
        {x: bb2.x + bb2.width / 2, y: bb2.y + bb2.height + 1},
        {x: bb2.x - 1, y: bb2.y + bb2.height / 2},
        {x: bb2.x + bb2.width + 1, y: bb2.y + bb2.height / 2}],
        d = {}, dis = [];
    for (var i = 0; i < 4; i++) {
        for (var j = 4; j < 8; j++) {
            var dx = Math.abs(p[i].x - p[j].x),
                dy = Math.abs(p[i].y - p[j].y);
            if ((i == j - 4) || (((i != 3 && j != 6) || p[i].x < p[j].x) && ((i != 2 && j != 7) || p[i].x > p[j].x) && ((i != 0 && j != 5) || p[i].y > p[j].y) && ((i != 1 && j != 4) || p[i].y < p[j].y))) {
                dis.push(dx + dy);
                d[dis[dis.length - 1]] = [i, j];
            }
        }
    }
    if (dis.length == 0) {
        var res = [0, 4];
    } else {
        res = d[Math.min.apply(Math, dis)];
    }
    var x1 = p[res[0]].x,
        y1 = p[res[0]].y,
        x4 = p[res[1]].x,
        y4 = p[res[1]].y;
    dx = Math.max(Math.abs(x1 - x4) / 2, 10);
    dy = Math.max(Math.abs(y1 - y4) / 2, 10);
    var x2 = [x1, x1, x1 - dx, x1 + dx][res[0]].toFixed(3),
        y2 = [y1 - dy, y1 + dy, y1, y1][res[0]].toFixed(3),
        x3 = [0, 0, 0, 0, x4, x4, x4 - dx, x4 + dx][res[1]].toFixed(3),
        y3 = [0, 0, 0, 0, y1 + dy, y1 - dy, y4, y4][res[1]].toFixed(3);
    var path = ["M", x1.toFixed(3), y1.toFixed(3), "C", x2, y2, x3, y3, x4.toFixed(3), y4.toFixed(3)].join(",");
    if (line && line.line) {
        line.bg && line.bg.attr({path: path});
        line.line.attr({path: path});
    } else {
        var color = typeof line == "string" ? line : "#000";
        return {
            bg: bg && bg.split && this.path(path).attr({stroke: bg.split("|")[0], fill: "none", "stroke-width": bg.split("|")[1] || 3}),
            line: this.path(path).attr({stroke: color, fill: "none"}),
            from: obj1,
            to: obj2
        };
    }
};

var el;
window.onload = function () {
    var dragger = function () {
        this.ox = this.type == "rect" || this.type=="image" ? this.attr("x") : this.attr("cx");
        this.oy = this.type == "rect" || this.type=="image" ? this.attr("y") : this.attr("cy");
        this.animate({"fill-opacity": .2}, 500);
    },
        move = function (dx, dy) {
            //var att = {x: this.ox + dx, y: this.oy + dy,cx: this.ox + dx, cy: this.oy + dy};
            var att = this.type == "rect" || this.type=="image" ? {x: this.ox + dx, y: this.oy + dy} : {cx: this.ox + dx, cy: this.oy + dy};
            //alert(this.ox);
            this.attr(att);
            for (var i = connections.length; i--;) {
                r.connection(connections[i]);
            }
            r.safari();
        },
        up = function () {
            this.animate({"fill-opacity": 0}, 500);
        },
        r = Raphael("holder", 800, 600),
        connections = [],
        shapes = [  r.image("http://localhost:3000/images/graph/windowsxp.png",0, 180, 80, 80),
                    r.image("http://localhost:3000/images/graph/windowsxp.png",290, 0, 80, 80),
                    r.image("http://localhost:3000/images/graph/windowsxp.png",100, 180, 80, 80),
                    r.image("http://localhost:3000/images/graph/windowsxp.png",100, 100, 80, 80),
                    r.image("http://localhost:3000/images/graph/windowsxp.png", 50, 50, 80, 80),
                    r.text(50+40, 50+80, "192.168.0.1")
                ];
      
    //var img = r.image("http://localhost:3000/images/fidius.png", 50, 50, 50, 50);
    //img.attr({cursor: "move"});
    //img.drag(move, dragger, up);

    for (var i = 0, ii = shapes.length; i < ii; i++) {
        //var color = Raphael.getColor();
        shapes[i].attr({fill: "#000", stroke: "#000", "fill-opacity": 0, "stroke-width": 1, cursor: "move"});
        shapes[i].drag(move, dragger, up);
    }
    connections.push(r.connection(shapes[0], shapes[1], "#000"));
    connections.push(r.connection(shapes[1], shapes[2], "#000"));
    connections.push(r.connection(shapes[1], shapes[3], "#000"));

  var json = r.serialize.json(); // saves as json
  //r.clear();
  alert(json);
  //r.serialize.load_json(json); // load it back

};


