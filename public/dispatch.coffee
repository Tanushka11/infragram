# This file is part of infragram-js.
#
# infragram-js is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# infragram-js is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with infragram-js.  If not, see <http://www.gnu.org/licenses/>.


webGlSupported = false
log = [] # a record of previous commands run


getURLParameter = (name) ->
    result = decodeURI(
        (RegExp(name + "=" + "(.+?)(&|$)").exec(location.search) || [null, null])[1]
    )
    return if result == "null" then null else result


setParametersFromURL = (idNameMap) ->
    for id, name of idNameMap
        val = getURLParameter(name)
        if val
            $(id).val(val)


updateImage = (img) ->
    if webGlSupported
        glUpdateImage(img)
    else
        jsUpdateImage(img)


$(document).ready(() ->
    $("#image-container").ready(() ->
        enablewebgl = if getURLParameter("enablewebgl") == "true" then true else false
        webGlSupported = enablewebgl && glInitInfragram()

        if webGlSupported
            $("#webgl-activate").html("&laquo; Go back to JS version")

        idNameMap =
            "#m_exp": "m"
            "#r_exp": "r"
            "#g_exp": "g"
            "#b_exp": "b"
            "#h_exp": "h"
            "#s_exp": "s"
            "#v_exp": "v"
        setParametersFromURL(idNameMap)

        src = getURLParameter("src")
        if src
            $("#download").show()
            $("#save-modal-btn").show()
            loadFileFromUrl(src, updateImage)

        return true
    )

    $("#file-sel").change(() ->
        $("#download").show()
        $("#save-modal-btn").show()
        handleOnChangeFile(this.files, updateImage)
        return true
    )

    $("button#raw").click(() ->
        log.push("raw")
        if webGlSupported
            glHandleOnClickRaw()
        else
            jsHandleOnClickRaw()
        return true
    )

    $("button#ndvi").click(() ->
        log.push("ndvi")
        if webGlSupported
            glHandleOnClickNdvi()
        else
            jsHandleOnClickNdvi()
        return true
    )

    $("button#nir").click(() ->
        log.push("nir")
        $("#m_exp").val("R")
        $("#modeSwitcher").val("infragrammar_mono").change()
        if webGlSupported
            glHandleOnSubmitInfraMono()
        else
            jsHandleOnSubmitInfraMono()
        return true
    )

    $("#download").click(() ->
        # create an "off-screen" anchor tag
        lnk = document.createElement("a")
        # the key here is to set the download attribute of the a tag
        lnk.download = (new Date()).toISOString().replace(/:/g, "_") + ".png"
        if webGlSupported
            lnk.href = glGetCurrentImage()
        else
            lnk.href = jsGetCurrentImage()

        # create a "fake" click-event to trigger the download
        if document.createEvent
            event = document.createEvent("MouseEvents")
            event.initMouseEvent(
                "click", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null)
            lnk.dispatchEvent(event)
        else if lnk.fireEvent
            lnk.fireEvent("onclick")

        return true
    )

    $("#save").click(() ->
        if webGlSupported
            img = glGetCurrentImage()
        else
            img = jsGetCurrentImage()
        sendThumbnail(img)

        $("#form-filename").val(getFilename())
        $("#form-log").val(JSON.stringify(log))
        $("#save-form").submit()
    )

    $("#infragrammar_hsv").submit(() ->
        log.push($("#h_exp").val())
        log.push($("#s_exp").val())
        log.push($("#v_exp").val())
        log.push("infragrammar_hsv")
        if webGlSupported
            glHandleOnSubmitInfraHsv()
        else
            jsHandleOnSubmitInfraHsv()
        return true
    )

    $("#infragrammar").submit(() ->
        log.push($("#r_exp").val())
        log.push($("#g_exp").val())
        log.push($("#b_exp").val())
        log.push("infragrammar")
        if webGlSupported
            glHandleOnSubmitInfra()
        else
            jsHandleOnSubmitInfra()
        return true
    )

    $("#infragrammar_mono").submit(() ->
        log.push($("#m_exp").val())
        log.push("infragrammar_mono")
        if webGlSupported
            glHandleOnSubmitInfraMono()
        else
            jsHandleOnSubmitInfraMono()
        return true
    )

    $("button#grey").click(() ->
        if webGlSupported
            glHandleOnClickGrey()
        else
            jsHandleOnClickGrey()
        return true
    )

    $("button#colorify").click(() ->
        if webGlSupported
            glHandleOnClickColorify()
        else
            jsHandleOnClickColorify()
        return true
    )

    $("button#color").click(() ->
        if webGlSupported
            glHandleOnClickColor()
        else
            jsHandleOnClickColor()
        return true
    )

    $("#slider").slider().on("slide", (event) ->
        if webGlSupported
            glHandleOnSlide(event)
        else
            jsHandleOnSlide(event)
        return true
    )

    $("#webgl-activate").click(() ->
        href = window.location.href
        if webGlSupported
            href = href.replace(/enablewebgl=true&?/gi, "")
        else
            href += if href.indexOf("?") >= 0 then "enablewebgl=true" else "?enablewebgl=true"
        window.location.href = href
        return true
    )

    $("#webcam-activate").click(() ->
        $("#download").show()
        $("#save-modal-btn").show()
        camera.initialize()
        return true
    )

    $("#snapshot").click(() ->
        camera.getSnapshot()
        return true
    )

    $("#exit-fullscreen").click(() ->
        $("#image").css("display", "inline")
        $("#image").css("position", "relative")
        $("#image").css("height", "auto")
        $("#image").css("left", 0)
        $("#backdrop").hide()
        $("#exit-fullscreen").hide()
        $("#fullscreen").show()
        return true
    )

    $("#fullscreen").click(() ->
        $("#image").css("display", "block")
        $("#image").css("height", "100%")
        $("#image").css("width", "auto")
        $("#image").css("position", "absolute")
        $("#image").css("top", "0px")
        $("#image").css("left", parseInt((window.innerWidth - $("#image").width()) / 2) + "px")
        $("#image").css("z-index", "2")
        $("#backdrop").show()
        $("#exit-fullscreen").show()
        $("#fullscreen").hide()
        return true
    )

    $("#live-video").click(() ->
        if webGlSupported
            setInterval(camera.getSnapshot, 33)
        else
            setInterval(camera.getSnapshot, 250)
        return true
    )

    $("#modeSwitcher").change(() ->
        $("#infragrammar, #infragrammar_mono, #infragrammar_hsv").hide()
        $("#" + $("#modeSwitcher").val()).css("display", "inline")
        return true 
    )

    return true
)