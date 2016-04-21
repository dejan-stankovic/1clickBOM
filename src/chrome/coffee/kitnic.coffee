# The contents of this file are subject to the Common Public Attribution
# License Version 1.0 (the “License”); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://1clickBOM.com/LICENSE. The License is based on the Mozilla Public
# License Version 1.1 but Sections 14 and 15 have been added to cover use of
# software over a computer network and provide for limited attribution for the
# Original Developer. In addition, Exhibit A has been modified to be consistent
# with Exhibit B.
#
# Software distributed under the License is distributed on an
# "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
# the License for the specific language governing rights and limitations under
# the License.
#
# The Original Code is 1clickBOM.
#
# The Original Developer is the Initial Developer. The Original Developer of
# the Original Code is Kaspar Emanuel.

{messenger} = require('./messenger')
window.postMessage({from:'extension', message:'register'}, '*')
messenger.send('getBackgroundState')

messenger.on 'updateKitnic', (interfaces) ->
    adding = {}
    for name, retailer of interfaces
        adding[name] = retailer.adding_lines
    window.postMessage({from:'extension', message:'updateAddingState', value:adding}, '*')

window.addEventListener 'message', (event) ->
    if event.source != window
        return
    if event.data.from == 'page'
        messenger.send(event.data.message, event.data.value)
, false
