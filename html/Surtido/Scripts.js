const accion = document.getElementById("accionMontacargas")
    const elevar = document.getElementById("idElevar")
    const bajar = document.getElementById("idBajar")
    const idUbicacion = document.getElementById("idUbicacion")
    const checkUbicacion = document.getElementById("checkUbicacion")
    let valorAccion = "Elevar"
    let valorUbicacion = ""
    
    elevar.addEventListener("click", e => {
        accion.textContent = "Elevar"
        valorAccion = "Elevar"
    })

    bajar.addEventListener("click", e => {
        accion.textContent = "Bajar"
        valorAccion = "Bajar"
    })

    idUbicacion.addEventListener("keydown", e => {
        if(event.key === 'Enter'){
            valorUbicacion = idUbicacion.value
            checkUbicacion.textContent = valorUbicacion
            idUbicacion.value = ""
        }
    })