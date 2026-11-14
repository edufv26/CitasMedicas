/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */
document.addEventListener("DOMContentLoaded", () => {
    // 1. Abrir cualquier modal usando el atributo data-abrir
    document.querySelectorAll("[data-abrir]").forEach(btn => {
        btn.addEventListener("click", () => {
            const modalId = btn.getAttribute("data-abrir");
            const modal = document.getElementById(modalId);
            if (modal) {
                modal.showModal();
            }
        });
    });

    // 2. Cerrar cualquier modal usando el botón con clase .btn-cerrar o atributo data-cerrar
    document.querySelectorAll("[data-cerrar], .btn-cerrar-modal").forEach(btn => {
        btn.addEventListener("click", () => {
            const modal = btn.closest("dialog");
            if (modal) {
                modal.close();
            }
        });
    });

    // 3. Opcional: Cerrar si hacen clic fuera del cuadro (en el fondo oscuro)
    document.querySelectorAll("dialog").forEach(modal => {
        modal.addEventListener("click", (e) => {
            const dims = modal.getBoundingClientRect();
            if (
                e.clientX < dims.left ||
                e.clientX > dims.right ||
                e.clientY < dims.top ||
                e.clientY > dims.bottom
            ) {
                modal.close();
            }
        });
    });
});

