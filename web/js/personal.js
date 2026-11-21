/* 
 - Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 - Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

function mostrarCamposExtra() {
    var selectTipo = document.getElementById("tipo");
    var divDentista = document.getElementById("seccion-dentista");
    var divSecretaria = document.getElementById("seccion-secretaria");

    if (!selectTipo || !divDentista || !divSecretaria) {
        return;
    }

    var tipo = selectTipo.value;

    divDentista.style.display = "none";
    divSecretaria.style.display = "none";

    if (tipo === "2") {
        divDentista.style.display = "block";
    } else if (tipo === "3") {
        divSecretaria.style.display = "block";
    }
}

function resetModalPassword() {
    var pasoConfirmar = document.getElementById("paso-confirmar-pass");
    var pasoForm = document.getElementById("paso-form-pass");
    var inputPass = document.getElementById("nuevaPassword");

    if (pasoConfirmar) {
        pasoConfirmar.style.display = "block";
    }
    if (pasoForm) {
        pasoForm.style.display = "none";
    }
    if (inputPass) {
        inputPass.required = false;
        inputPass.value = "";
    }
}

function confirmarNuevaPassword() {
    var pasoConfirmar = document.getElementById("paso-confirmar-pass");
    var pasoForm = document.getElementById("paso-form-pass");
    var inputPass = document.getElementById("nuevaPassword");
    var usr = document.getElementById("passUsuario") ? document.getElementById("passUsuario").value : "";
    var formTexto = document.getElementById("passUsuarioFormTexto");

    if (formTexto) {
        formTexto.textContent = usr;
    }
    if (pasoConfirmar) {
        pasoConfirmar.style.display = "none";
    }
    if (pasoForm) {
        pasoForm.style.display = "block";
    }
    if (inputPass) {
        inputPass.required = true;
        inputPass.focus();
    }
}

function abrirModalPassword(usuario) {
    var inputUsuario = document.getElementById("passUsuario");
    var textoUsuario = document.getElementById("passUsuarioTexto");
    var dlg = document.getElementById("modalPassword");

    resetModalPassword();

    if (inputUsuario) {
        inputUsuario.value = usuario;
    }
    if (textoUsuario) {
        textoUsuario.textContent = usuario;
    }
    if (dlg) {
        if (typeof dlg.showModal === "function") {
            if (!dlg.open) {
                dlg.showModal();
            }
        } else {
            dlg.setAttribute("open", "");
        }
    }
}

function aplicarFiltroPersonal() {
    var selectTipo = document.getElementById("fPerTipo");
    var inputBuscar = document.getElementById("fPerBuscar");

    var tipo = selectTipo ? selectTipo.value : "todos";
    var texto = (inputBuscar ? inputBuscar.value : "").trim().toLowerCase();

    var bloques = document.querySelectorAll("[data-rol-personal]");
    bloques.forEach(function (bloque) {
        var rolBloque = bloque.getAttribute("data-rol-personal");
        var mostrarBloque = (tipo === "todos") || (tipo === rolBloque);

        bloque.style.display = mostrarBloque ? "" : "none";

        var tbody = bloque.querySelector("tbody");
        if (!tbody) {
            return;
        }

        // Limpia filas previas de "Sin coincidencias" generadas por el filtro
        var prevSinCoincidencias = tbody.querySelectorAll("tr.fila-sin-coincidencias");
        prevSinCoincidencias.forEach(function (tr) {
            tr.remove();
        });

        var filas = Array.prototype.slice.call(tbody.querySelectorAll("tr"));
        var filasVisibles = 0;

        filas.forEach(function (fila) {
            // Ignora filas vacías originales de BD (con colspan)
            if (fila.cells.length === 1 && fila.cells[0].hasAttribute("colspan")) {
                fila.style.display = mostrarBloque ? "" : "none";
                return;
            }

            if (!mostrarBloque) {
                fila.style.display = "none";
                return;
            }

            var contenido = (fila.textContent || "").toLowerCase();
            var coincide = !texto || contenido.includes(texto);

            fila.classList.remove("fila-filtrada");
            if (coincide) {
                fila.style.display = "";
                void fila.offsetWidth;
                fila.classList.add("fila-filtrada");
                filasVisibles++;
            } else {
                fila.style.display = "none";
            }
        });

        // Si el bloque está visible pero no hubo coincidencias, agrega la fila de aviso
        var tieneFilaVaciaOriginal = filas.some(function (fila) {
            return fila.cells.length === 1 && fila.cells[0].hasAttribute("colspan");
        });

        if (mostrarBloque && filasVisibles === 0 && !tieneFilaVaciaOriginal) {
            var numColumnas = 5;
            var theadCols = bloque.querySelectorAll("thead th");
            if (theadCols && theadCols.length > 0) {
                numColumnas = theadCols.length;
            }

            var trAviso = document.createElement("tr");
            trAviso.className = "fila-sin-coincidencias fila-filtrada";

            var tdAviso = document.createElement("td");
            tdAviso.setAttribute("colspan", String(numColumnas));
            tdAviso.className = "text-center sin-coincidencias";
            tdAviso.style.padding = "16px";
            tdAviso.style.opacity = "0.75";
            tdAviso.textContent = "Sin coincidencias.";

            trAviso.appendChild(tdAviso);
            tbody.appendChild(trAviso);
        }
    });
}

document.addEventListener("DOMContentLoaded", function () {
    var bodyEl = document.body;
    if (bodyEl && bodyEl.getAttribute("data-es-edicion") === "true") {
        var tipoEdicion = bodyEl.getAttribute("data-tipo-edicion");
        var turnoDen = bodyEl.getAttribute("data-turno-dentista");
        var turnoSec = bodyEl.getAttribute("data-turno-secretaria");

        var selectTipo = document.getElementById("tipo");
        if (selectTipo && tipoEdicion && tipoEdicion !== "0") {
            selectTipo.value = tipoEdicion;
        }
        var selectTurnoDen = document.getElementById("turnoDentista");
        if (selectTurnoDen && turnoDen) {
            selectTurnoDen.value = turnoDen;
        }
        var selectTurnoSec = document.getElementById("turnoSecretaria");
        if (selectTurnoSec && turnoSec) {
            selectTurnoSec.value = turnoSec;
        }
    }

    mostrarCamposExtra();

    var dlgRegistro = document.getElementById("modalRegistro");
    if (dlgRegistro && dlgRegistro.hasAttribute("open") && typeof dlgRegistro.showModal === "function") {
        dlgRegistro.removeAttribute("open");
        dlgRegistro.showModal();
        mostrarCamposExtra();
    }

    var btnFiltrar = document.getElementById("btnFiltrarPersonal");
    var btnLimpiar = document.getElementById("btnLimpiarPersonal");
    var selectTipoFiltro = document.getElementById("fPerTipo");
    var inputBuscar = document.getElementById("fPerBuscar");

    if (btnFiltrar) {
        btnFiltrar.addEventListener("click", aplicarFiltroPersonal);
    }

    if (btnLimpiar) {
        btnLimpiar.addEventListener("click", function () {
            if (selectTipoFiltro)
                selectTipoFiltro.value = "todos";
            if (inputBuscar)
                inputBuscar.value = "";
            aplicarFiltroPersonal();
        });
    }

});