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
        divSecretaria.style.display = "block";
    } else if (tipo === "3") {
        divDentista.style.display = "block";
    }
}

function resetModalPassword() {
    var pasoConfirmar = document.getElementById("paso-confirmar-pass");
    var pasoForm = document.getElementById("paso-form-pass");
    var inputPass = document.getElementById("nuevaPassword");
    var icono = document.getElementById("iconoOjitoPass");

    if (pasoConfirmar) {
        pasoConfirmar.style.display = "block";
    }
    if (pasoForm) {
        pasoForm.style.display = "none";
    }
    if (inputPass) {
        inputPass.type = "password";
        inputPass.required = false;
        inputPass.value = "";
    }
    if (icono) {
        icono.className = "fa fa-eye";
    }
}

function regenerarPasswordModal() {
    var inputUsr = document.getElementById("passUsuario");
    var usr = inputUsr ? inputUsr.value.trim() : "";
    if (!usr) {
        return;
    }
    window.location.href = "Control?accion=regenerarPassword&usuario=" + encodeURIComponent(usr);
}

function confirmarNuevaPassword() {
    regenerarPasswordModal();
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

function toggleVisibilidadPassword() {
    var inputPass = document.getElementById("nuevaPassword");
    var icono = document.getElementById("iconoOjitoPass");
    if (!inputPass) {
        return;
    }

    var esPassword = (inputPass.type === "password");
    inputPass.type = esPassword ? "text" : "password";

    if (icono) {
        icono.className = esPassword ? "fa fa-eye-slash" : "fa fa-eye";
    }
}

function cerrarModalRespuesta() {
    var dlg = document.getElementById("modalRespuesta");
    if (!dlg || !dlg.open) {
        return;
    }
    dlg.classList.add("cerrando");
    setTimeout(function () {
        dlg.classList.remove("cerrando");
        if (typeof dlg.close === "function") {
            dlg.close();
        } else {
            dlg.removeAttribute("open");
        }
    }, 240);
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

    var dlgRegistro = document.getElementById("modalRegistro");
    if (dlgRegistro && dlgRegistro.hasAttribute("open") && typeof dlgRegistro.showModal === "function") {
        dlgRegistro.removeAttribute("open");
        dlgRegistro.showModal();
    }

    mostrarCamposExtra();

    var dlgPass = document.getElementById("modalPassword");
    if (dlgPass && dlgPass.getAttribute("data-abrir-paso") === "true") {
        var pasoConfirmar = document.getElementById("paso-confirmar-pass");
        var pasoForm = document.getElementById("paso-form-pass");
        var formTexto = document.getElementById("passUsuarioFormTexto");
        var usrVal = document.getElementById("passUsuario") ? document.getElementById("passUsuario").value.trim() : "";

        if (formTexto && usrVal) {
            formTexto.textContent = usrVal;
        }
        if (pasoConfirmar) {
            pasoConfirmar.style.display = "none";
        }
        if (pasoForm) {
            pasoForm.style.display = "block";
        }
        if (typeof dlgPass.showModal === "function" && !dlgPass.open) {
            dlgPass.showModal();
        }
    }

    var mensajeResp = bodyEl ? (bodyEl.getAttribute("data-mensaje-respuesta") || "").trim() : "";
    var dlgResp = document.getElementById("modalRespuesta");
    var txtResp = document.getElementById("mensajeRespuestaTexto");

    if (mensajeResp && dlgResp) {
        if (txtResp) {
            txtResp.textContent = mensajeResp;
        }
        if (typeof dlgResp.showModal === "function") {
            if (!dlgResp.open) {
                dlgResp.showModal();
            }
        } else {
            dlgResp.setAttribute("open", "");
        }
    }

    var formRegistro = dlgRegistro ? dlgRegistro.querySelector("form") : null;
    if (formRegistro) {
        formRegistro.addEventListener("submit", function (e) {
            var accionInput = formRegistro.querySelector("input[name='accion']");
            var accion = accionInput ? accionInput.value : "";

            if (accion !== "registrarPersonal") {
                return;
            }

            var nombreEl = document.getElementById("nombre");
            var paternoEl = document.getElementById("APaterno");
            var tipoEl = document.getElementById("tipo");

            var nombre = nombreEl ? nombreEl.value.trim() : "";
            var paterno = paternoEl ? paternoEl.value.trim() : "";
            var tipo = tipoEl ? tipoEl.value.trim() : "";

            if (!nombre || !paterno || !tipo) {
                e.preventDefault();
                alert("Completa los campos obligatorios: nombre, apellido paterno y tipo de personal.");
                var focoBase = !nombre ? nombreEl : (!paterno ? paternoEl : tipoEl);
                if (focoBase) {
                    focoBase.focus();
                }
                return;
            }

            if (tipo === "2") {
                var turnoSecEl = document.getElementById("turnoSecretaria");
                var turnoSec = turnoSecEl ? turnoSecEl.value.trim() : "";
                if (!turnoSec) {
                    e.preventDefault();
                    alert("Selecciona el turno para Secretaria.");
                    if (turnoSecEl) {
                        turnoSecEl.focus();
                    }
                }
            } else if (tipo === "3") {
                var espEl = document.getElementById("especialidad");
                var cedEl = document.getElementById("cedula");
                var turnoDenEl = document.getElementById("turnoDentista");

                var esp = espEl ? espEl.value.trim() : "";
                var ced = cedEl ? cedEl.value.trim() : "";
                var turnoDen = turnoDenEl ? turnoDenEl.value.trim() : "";

                if (!esp || !ced || !turnoDen) {
                    e.preventDefault();
                    alert("Para Dentista debes capturar especialidad, cédula profesional y turno.");
                    var focoDen = !esp ? espEl : (!ced ? cedEl : turnoDenEl);
                    if (focoDen) {
                        focoDen.focus();
                    }
                }
            }
        });
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