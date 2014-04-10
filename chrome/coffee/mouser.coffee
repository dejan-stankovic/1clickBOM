# This file is part of 1clickBOM.
#
# 1clickBOM is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License version 3
# as published by the Free Software Foundation.
#
# 1clickBOM is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with 1clickBOM.  If not, see <http://www.gnu.org/licenses/>.

class @Mouser extends RetailerInterface
    constructor: (country_code, settings) ->
        super "Mouser", country_code, "/data/mouser_international.json", settings
        @icon_src = chrome.extension.getURL("images/mouser.ico")
        #posting our sub-domain as the sites are all linked and switching countries would not register properly otherwise
        xhr = new XMLHttpRequest
        xhr.open("POST", "http://uk.mouser.com/api/Preferences/SetSubdomain?subdomainName=" + @cart.split(".")[0].slice(3), true)
        xhr.send()
    addItems: (items, callback) ->
        #weird ASP shit, we need to get the viewstate first to put in every request
        @_get_adding_viewstate (that, viewstate) ->
            that._add_items(items, viewstate, callback)
    _add_items: (items, viewstate, callback) ->
        that = this
        params = that.additem_params + viewstate
        params += "&ctl00$ContentMain$hNumberOfLines=99"
        params += "&ctl00$ContentMain$txtNumberOfLines=94"
        for item,i in items
            params += "&ctl00$ContentMain$txtCustomerPartNumber" + (i+1) + "=" + item.comment
            params += "&ctl00$ContentMain$txtPartNumber" + (i+1) + "=" + item.part
            params += "&ctl00$ContentMain$txtQuantity"   + (i+1) + "=" + item.quantity
        #use uk here so the response is in english
        url = "http://uk.mouser.com" + that.additem
        xhr = new XMLHttpRequest
        xhr.open("POST", url, true)
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        request = {success: true, fails:[]}
        xhr.onreadystatechange = (event) ->
            if event.currentTarget.readyState == 4
                #if there is an error, there will be some error-class items with display set to ""
                doc = (new DOMParser).parseFromString(event.currentTarget.responseText, "text/html")
                errors = doc.getElementsByClassName("error")
                for error in errors
                    if error.style.display == ""
                        detail_div = error.querySelectorAll("div")[1]
                        if detail_div?
                            part = /\n(.*)<br>/.exec(detail_div.innerHTML)[1]
                            for item in items
                                if item.part == part
                                    request.fails.push(item)
                        request.success = false
                if not request.success
                    viewstate = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
                    that._clear_errors that, viewstate, () ->
                        if callback?
                            callback(request, that)
                        that.refreshCartTabs()
                else
                    if callback?
                        callback(request, that)
                    that.refreshCartTabs()
        xhr.send(params)

    _clear_errors: (that, viewstate, callback) ->
        xhr = new XMLHttpRequest
        xhr.open("POST", "http://uk.mouser.com" + that.cart, true)
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        xhr.onreadystatechange = () ->
            if xhr.readyState == 4
                doc = new DOMParser().parseFromString(xhr.responseText, "text/html")
                viewstate = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
                xhr2 = new XMLHttpRequest
                xhr2.open("POST", "http://uk.mouser.com" + that.cart, true)
                xhr2.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
                xhr2.onreadystatechange = () ->
                    if xhr2.readyState == 4
                        if callback?
                            callback(that)
                xhr2.send("__EVENTARGUMENT=&__EVENTTARGET=&__SCROLLPOSITIONX=&__SCROLLPOSITIONY=&__VIEWSTATE=" + viewstate + "&__VIEWSTATEENCRYPTED=&ctl00$ContentMain$btn7=Update Basket")
        xhr.send("__EVENTARGUMENT=&__EVENTTARGET=&__SCROLLPOSITIONX=&__SCROLLPOSITIONY=&__VIEWSTATE=" + viewstate + "&__VIEWSTATEENCRYPTED=&ctl00$ctl00$ContentMain$btn3=Errors")

    clearCart: () ->
        @_get_cart_viewstate (that, viewstate) ->
            that._clear_cart(viewstate)
    _clear_cart: (viewstate)->
        that = this
        xhr = new XMLHttpRequest
        xhr.open("POST", "http" + @site + @cart, true)
        xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        xhr.onreadystatechange = () ->
            if xhr.readyState == 4
                that.refreshCartTabs()
        #don't ask, this is what works...
        xhr.send("__EVENTARGUMENT=&__EVENTTARGET=&__SCROLLPOSITIONX=&__SCROLLPOSITIONY=&__VIEWSTATE=" + viewstate + "&__VIEWSTATEENCRYPTED=&ctl00$ContentMain$btn7=Update Basket")
    _get_adding_viewstate: (callback)->
        #we get the quick-add form , extend it to 99 lines (the max) and get the viewstate from the response
        that = this
        url = "http" + @site + @additem
        xhr = new XMLHttpRequest
        xhr.open "GET", url, true
        xhr.onreadystatechange = (data) ->
            if xhr.readyState == 4 and xhr.status == 200
                doc = new DOMParser().parseFromString(xhr.responseText, "text/html")
                params = that.additem_params
                params += encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
                params += "&ctl00$ContentMain$btnAddLines=Lines to Forms"
                params += "&ctl00$ContentMain$hNumberOfLines=5"
                params += "&ctl00$ContentMain$txtNumberOfLines=94"
                xhr2 = new XMLHttpRequest
                xhr2.open("POST", url, true)
                xhr2.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
                xhr2.onreadystatechange = (data) ->
                    if xhr2.readyState == 4 and xhr2.status == 200
                        doc = new DOMParser().parseFromString(xhr2.responseText, "text/html")
                        viewstate = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
                        if callback?
                            callback(that, viewstate)
                xhr2.send(params)
        xhr.send()
    _get_cart_viewstate: (callback)->
        that = this
        url = "http" + @site + @cart
        xhr = new XMLHttpRequest
        xhr.open "GET", url, true
        xhr.onreadystatechange = (data) ->
            if xhr.readyState == 4 and xhr.status == 200
                doc = new DOMParser().parseFromString(xhr.responseText, "text/html")
                viewstate = encodeURIComponent(doc.getElementById("__VIEWSTATE").value)
                if callback?
                    callback(that, viewstate)
        xhr.send()
