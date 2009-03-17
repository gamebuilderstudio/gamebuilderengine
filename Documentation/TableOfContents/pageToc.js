//Change top to the id of the parent element that contains all of the headers. Change toc to the idea o f the div you added to the page
window.onload = function(){new tocGen('contentArea','pageToc')};
//This script was written By Brady Mulhollem - WebTech101.com
function tocGen(id,writeTo){
	this.id = id;
	this.num = 0;
	this.opened = 0;
	this.writeOut = '<h3>Page Contents</h3>';
	this.previous = 0;
	if(document.getElementById){
		//current requirements;
		this.parentOb = document.getElementById(id);
		var headers = this.getHeaders(this.parentOb);
		if(headers.length > 0){
			this.writeOut += '<ul>';
			var num;
			for(var i=0;i<headers.length;i++){
				num = headers[i].nodeName.substr(1) - 2;
				if(num > this.previous){
					this.writeOut += '<ul>';
					this.opened++;
					this.addLink(headers[i]);
				}
				else if(num < this.previous){
					for(var j=0;j<this.opened;j++){
						this.writeOut += '<\/li><\/ul>';
						this.opened--;
					}
					this.addLink(headers[i]);
				}
				else{
					this.writeout += '<\/li>';
					this.addLink(headers[i]);
				}
				this.previous = num;
			}
			for(var j=0;j<=this.opened;j++){
				this.writeOut += '<\/li><\/ul>';
			}
			document.getElementById(writeTo).innerHTML = this.writeOut;
		}
	}
}
tocGen.prototype.addLink = function(ob){
	var id = this.getId(ob);
	var link = '<li><a href="#'+id+'">'+ob.innerHTML+'<\/a>';
	this.writeOut += link;
}
tocGen.prototype.getId = function(ob){
	if(!ob.id){
		ob.id = this.id+'toc'+this.num;
		this.num++;
	}
	return ob.id;
}
tocGen.prototype.getHeaders = function(parent){
	var return_array = new Array();
	var pat = new RegExp("H[1-6]");
	for(var i=0;i<parent.childNodes.length;i++){
		if(pat.test(parent.childNodes[i].nodeName)){
			return_array[return_array.length] = parent.childNodes[i];
		}
	}
	return return_array;
}
