function buttonDivAction() {
	window.webkit.messageHandlers.currentCookies.postMessage({
		"body": "buttonActionMessage"
	});
}

function alertAction(message) {
	
	alert(message + " " + "我是js中的代码");
	
}
