﻿<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<%@ Page Language="C#" %>
<%@ Register tagprefix="SharePoint" namespace="Microsoft.SharePoint.WebControls" assembly="Microsoft.SharePoint, Version = 15.0.0.0, Culture = neutral, PublicKeyToken = 71e9bce111e9429c" %>
<html dir="ltr" xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<!--Documento generado de manera dinámica por SPFormsEasy -->
<!--Nombre del documento: ExtravioViaPublicaProducto -->
<!--Creado por: Luis Alonso Escalona Morales -->
<!--Creado el: 11/03/2018 -->
<SharePoint:ScriptLink Name="MicrosoftAjax.js" runat="server" Defer="False" Localizable="false"/>
<SharePoint:ScriptLink Name="SP.core.js" runat="server" Defer="False" Localizable="false"/>
<SharePoint:ScriptLink Name="SP.js" runat="server" Defer="False" Localizable="false"/>
<SharePoint:ScriptLink Name="SP.runtime.js" runat="server" Defer="False" Localizable="false"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=10" />
<SharePoint:CssRegistration Name="default" runat="server"/>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datetimepicker/4.17.45/css/bootstrap-datetimepicker.css"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datetimepicker/4.17.45/css/bootstrap-datetimepicker.min.css"/>
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
<script type="text/javascript" src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.17.1/moment.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datetimepicker/4.17.45/js/bootstrap-datetimepicker.min.js"></script>
<script type="text/javascript" src="https://cocacolafemsa.sharepoint.com/sites/SWPP/_layouts/15/SP.Runtime.js"></script>
<script type="text/javascript" src="https://cocacolafemsa.sharepoint.com/sites/SWPP/_layouts/15/SP.js"></script>
<script type="text/javascript" src="https://cocacolafemsa.sharepoint.com/sites/SWPP/_layouts/15/SP.UserProfiles.js"></script>
<link rel="stylesheet" href="../../../Styles/reportes.css"/>
<script type="text/javascript" src="../../../Scripts/Sitios/Alarma.js"></script>
<script type="text/javascript" src="../../../Scripts/Sitios/combo_min.js"></script>
<script type="text/javascript" src="../../../Scripts/Traduccion.js"></script>
<script type="text/javascript" src="../../../Scripts/jquery.priceformat.min.js"></script>
<script type="text/javascript" src="../../../Scripts/jquery.number.min.js"></script>

<link rel="stylesheet" href="../../../Styles/inputmask.css"/>
<script type="text/javascript" src="../../../Scripts/dist/jquery.inputmask.bundle.js"></script>

<!--JS Operación-->
<script type ="text/javascript">
	var cont_PersonasInvolucradas = 0;
	var cont_Producto = 0;
	var personProperties;
	var clientContext;
	var etiquetascontroles = [];
	var pais;
	var URL = "https://cocacolafemsa.sharepoint.com/sites/SWPP";
	$(document).ready(function () {
		SP.SOD.executeOrDelayUntilScriptLoaded(getCurrentUser, 'SP.UserProfiles.js');
		$('#NumeroPersonasInvolucradas').on('click', contarPersonasInvolucradas);
		$('#NumeroProducto').on('click', contarProducto);
		$('#btnAgregar').on('click', agregar);
		$('#HNBR').text($.get('NBR'));


		$('.time').on('focus blur', validaHora);
		$('.time').datetimepicker({
			format: 'HH:mm'
		});

		$('.date').datetimepicker({
			format: 'DD/MM/YYYY'
		});

		$('.moneda').inputmask('currency');

		$('.numero').inputmask('numeric');

	});

	function validaHora(){
		var h1 = $('#txtHoraOcurre').val();
		var h2 = $('#txtHoraFinaliza').val();
		if (!compararHoras(h1, h2))
		{
			$('#txtHoraOcurre').css('border-color', 'red');
			$('#txtHoraFinaliza').css('border-color', 'red');
		}
		else
		{
			$('#txtHoraOcurre').css('border-color', '#D8D8D8');
			$('#txtHoraFinaliza').css('border-color', '#D8D8D8');
		}
	}

	function agregar(){
		if (validarCampos())
		{
			if ($('#hdngua').val() == 'true'){
				if (confirm($('#lblAgregarAviso').text()))
				{
				guardarDatosB(obtener(), clientContext);
				clientContext.executeQueryAsync(Function.createDelegate(this, this.onGuardarExitoB), Function.createDelegate(this, this.onGuardarErrorB));
					setTimeout('window.close()', 5000);
				}
			}else{
				console.log('Editar');
				EliminarReporte($('#hdnidentificador').val(), $('#hdnnumero').val());
EliminarDatosPersonasInvolucradas($('#hdnidentificador').val(), $('#hdnnumero').val());
EliminarDatosProducto($('#hdnidentificador').val(), $('#hdnnumero').val());
				guardarDatosB(obtener(), clientContext);
				clientContext.executeQueryAsync(Function.createDelegate(this, this.onGuardarExitoB), Function.createDelegate(this, this.onGuardarErrorB));
				setTimeout('window.close()', 5000);
			}
		}
		else
		{
			alert($('#lblCamposFaltantes').text());
		}
	}

	function EliminarDatos(lista, id, clientContext){
		var oList = clientContext.get_web().get_lists().getByTitle(lista);
		this.oListItem = oList.getItemById(id);
		oListItem.deleteObject();
	}
	function EliminarReporte(folio, reporte) {
		$.ajax({
			url: URL + "/_api/web/lists/getbytitle('TR_Extravio')/Items?$select=ID&$filter=Title eq '" + encodeURIComponent(folio) + "' and NumeroReporte eq '" + encodeURIComponent(reporte) + "'", 
			type: "GET", 
			async: false,
			headers:{"accept":"application/json;odata=verbose"}, 
			success: function (data) { 
				if (data.d.results) { 
					EliminarDatos('TR_Extravio', data.d.results[0].ID, clientContext);
				} 
			}, 
			error: function (xhr) { 
				alert('EliminarReporte ' + xhr.status + ': ' + xhr.statusText); 
			}
		});
	}
	function EliminarDatosPersonasInvolucradas(folio, reporte){
		$.ajax({ 
			url: URL + "/_api/web/lists/getbytitle('DN_PersonasInvolucradas')/Items?$select=ID&$filter=Folio eq '"+encodeURIComponent(folio)+"' and NoReporte eq '"+encodeURIComponent(reporte)+"'", 
			type: "GET", 
			async: false,
			headers:{"accept":"application/json;odata=verbose"}, 
			success: function (data) {
				if (data.d.results) {
					for(var i = 0; i < data.d.results.length;i++){
						EliminarDatos('DN_PersonasInvolucradas', data.d.results[i].ID, clientContext);
					} 
				} 
			},
			error: function (xhr) { 
				alert('Eliminar Datos ' + xhr.status + ': ' + xhr.statusText); 
			} 
		}); 
	}



	function EliminarDatosProducto(folio, reporte){
		$.ajax({ 
			url: URL + "/_api/web/lists/getbytitle('DN_Producto')/Items?$select=ID&$filter=Folio eq '"+encodeURIComponent(folio)+"' and NoReporte eq '"+encodeURIComponent(reporte)+"'", 
			type: "GET", 
			async: false,
			headers:{"accept":"application/json;odata=verbose"}, 
			success: function (data) {
				if (data.d.results) {
					for(var i = 0; i < data.d.results.length;i++){
						EliminarDatos('DN_Producto', data.d.results[i].ID, clientContext);
					} 
				} 
			},
			error: function (xhr) { 
				alert('Eliminar Datos ' + xhr.status + ': ' + xhr.statusText); 
			} 
		}); 
	}



	function guardarDatosB(datos, clientContext) {
		guardarReporteB(datos[0], clientContext);
		var info = JSON.parse(datos[0]);
		for(var i = 0; i<datos[1].length; i++) {
		guardarReportePersonasInvolucradasB(datos[1][i], info.Identificador, info.NumeroReporte, info.Estatus, clientContext);
		}

		for(var i = 0; i<datos[2].length; i++) {
		guardarReporteProductoB(datos[2][i], info.Identificador, info.NumeroReporte, info.Estatus, clientContext);
		}

	}

	function guardarReporteB(d, clientContext) {
		try {
			var datos = JSON.parse(d);
			var oList = clientContext.get_web().get_lists().getByTitle('TR_Extravio');
			var itemCreateInfo = new SP.ListItemCreationInformation();
			this.oListItemDatos = oList.addItem(itemCreateInfo);

			oListItemDatos.set_item('Title', datos.Identificador);
			oListItemDatos.set_item('NombreReporte', datos.NombreReporte );
			oListItemDatos.set_item('NumeroReporte', datos.NumeroReporte );
			oListItemDatos.set_item('Estatus', datos.Estatus );
			oListItemDatos.set_item('HoraOcurre', datos.HoraOcurre);
			oListItemDatos.set_item('HoraFinaliza', datos.HoraFinaliza);
			oListItemDatos.set_item('HoraReportanProteccion', datos.HoraReportanProteccion);
			oListItemDatos.set_item('NombrePersonaReportaProteccion', datos.NombrePersonaReportaProteccion);
			oListItemDatos.set_item('PuestoPersonaReportaProteccion', datos.PuestoPersonaReportaProteccion);
			oListItemDatos.set_item('MontoRecuperacion', datos.MontoRecuperacion);
			oListItemDatos.set_item('MontoProducto', datos.MontoProducto);
			oListItemDatos.set_item('MontoAproximadoProducto', datos.MontoAproximadoProducto);
			oListItemDatos.set_item('MontoTotal', datos.MontoTotal);
			oListItemDatos.set_item('ObservacionesInformacionAdiciona', datos.ObservacionesInformacionAdiciona);

			oListItemDatos.update();
			clientContext.load(oListItemDatos);
		}catch (e) {
			alert(e);
		}
	}

	function guardarReportePersonasInvolucradasB(d, padre, numero, estatus, clientContext) { 
		try {
			var datos = JSON.parse(d);
			var oList = clientContext.get_web().get_lists().getByTitle('DN_PersonasInvolucradas');
			var itemCreateInfo = new SP.ListItemCreationInformation();
			this.oListItemDatos = oList.addItem(itemCreateInfo);

			oListItemDatos.set_item('Folio', padre );
			oListItemDatos.set_item('NoReporte', numero );
			oListItemDatos.set_item('Estatus', estatus);
			oListItemDatos.set_item('NombrePersona', datos.NombrePersona);
			oListItemDatos.set_item('Area', datos.Area);
			oListItemDatos.set_item('NoEmpleado', datos.NoEmpleado);
			oListItemDatos.set_item('Empresa', datos.Empresa);

			oListItemDatos.update();
			clientContext.load(oListItemDatos);
		}catch (e) {
			alert(e);
		}
	}

	function guardarReporteProductoB(d, padre, numero, estatus, clientContext) { 
		try {
			var datos = JSON.parse(d);
			var oList = clientContext.get_web().get_lists().getByTitle('DN_Producto');
			var itemCreateInfo = new SP.ListItemCreationInformation();
			this.oListItemDatos = oList.addItem(itemCreateInfo);

			oListItemDatos.set_item('Folio', padre );
			oListItemDatos.set_item('NoReporte', numero );
			oListItemDatos.set_item('Estatus', estatus);
			oListItemDatos.set_item('Producto', datos.Producto);
			oListItemDatos.set_item('Cantidad', datos.Cantidad);
			oListItemDatos.set_item('MontoUnitario', datos.MontoUnitario);
			oListItemDatos.set_item('Total', datos.Total);

			oListItemDatos.update();
			clientContext.load(oListItemDatos);
		}catch (e) {
			alert(e);
		}
	}

	function onGuardarExitoB() {
		console.log('Guardado');
	}

	function onGuardarErrorB(sender, args) {
		alert('Request failed. ' + args.get_message() + '\n' + args.get_stackTrace());
}

	function getCurrentUser() {
		clientContext = new SP.ClientContext.get_current();
		personProperties = new SP.UserProfiles.PeopleManager(clientContext).getMyProperties();
		clientContext.load(personProperties);
		clientContext.executeQueryAsync(gotAccount, requestFailed);
	}

	function gotAccount(sender, args) {
		var id = $.get('ID');
		var estado = $.get('EDO');
		var numero = $.get('NUM');
		var cuenta = personProperties.get_accountName().split('|')[2];
		pais = obtenerPaisUsuario(cuenta);


		var URLSitio = "https://cocacolafemsa.sharepoint.com/sites/SWPP"; 
		if (pais == "BR") {
			TraducirIdiomaNP("Portugu&#233;s", URLSitio, "Incidencias.aspx");
		}else{
			if (pais == "PH") {
				TraducirIdiomaNP("Inglés", URLSitio, "Incidencias.aspx");
			}else {
				TraducirIdiomaNP("Español", URLSitio, "Incidencias.aspx");
			}
		}
		if(id != null && numero != null && estado != null) {
			$('#hdnidentificador').val(id);
			$('#hdnnumero').val(numero);

			if(estado == 'Edit') {
				llenarDatos(id, numero);

				llenarDatosPersonasInvolucradas(id, numero);

				llenarDatosProducto(id, numero);

				$('#hdngua').val(false);
			}
			if(estado == 'Ver') {
				llenarDatos(id, numero);

				llenarDatosPersonasInvolucradas(id, numero);

				llenarDatosProducto(id, numero);

				bloquear();
				$('#hdngua').val(false);
			}
		}
	}
	function llenarDatosPersonasInvolucradas(folio, reporte){
		$.ajax({
			url:URL + "/_api/web/lists/getbytitle('DN_PersonasInvolucradas')/Items?$select=ID&$filter=Folio eq '" + encodeURIComponent(folio) + "' and NoReporte eq '" + encodeURIComponent(reporte) + "'",
			type: "GET",
async: false,
			headers: {"accept": "application/json;odata=verbose"},
			success: function(data) {
				if(data.d.results) {
					for(var i = 0; i < data.d.results.length; i++) {
						$('#NumeroPersonasInvolucradas').click();
					}
					for(var i = 0; i < data.d.results.length; i++) {
						obtenerPersonasInvolucradas(data.d.results[i].ID, i + 1);
					}
				}
			},
			error: function (xhr) {
				alert('llenar Datos PersonasInvolucradas ' + xhr.status + ': ' + xhr.statusText);
			}
		});
	}

	function obtenerPersonasInvolucradas(identificador, campo) {
		$.ajax({
			url:URL + "/_api/web/lists/getbytitle('DN_PersonasInvolucradas')/Items?$select= NombrePersona,Area,NoEmpleado,Empresa&$orderby=ID &$filter=ID eq '" + encodeURIComponent(identificador) + "'",
			type: "GET",
async: false,
			headers: {"accept": "application/json;odata=verbose"},
			success: function (data) {
				if (data.d.results) {
					$('#txtNombrePersonasInvolucradas' + campo).val(data.d.results[0].NombrePersona);
					$('#txtAreaPersonasInvolucradas' + campo).val(data.d.results[0].Area);
					$('#txtNumeroEmpleadoPersonasInvolucradas' + campo).val(data.d.results[0].NoEmpleado);
					$('#txtEmpresaPersonasInvolucradas' + campo).val(data.d.results[0].Empresa);
					if($.get('EDO') == 'Ver') {
						$('#txtNombrePersonasInvolucradas' + campo).prop('disabled', true);
						$('#txtAreaPersonasInvolucradas' + campo).prop('disabled', true);
						$('#txtNumeroEmpleadoPersonasInvolucradas' + campo).prop('disabled', true);
						$('#txtEmpresaPersonasInvolucradas' + campo).prop('disabled', true);
					}
				}
			},
			error: function (xhr) {
				alert('obtenerPersonasInvolucradas ' + xhr.status + ': ' + xhr.statusText);
			}
		});
	}
	function llenarDatosProducto(folio, reporte){
		$.ajax({
			url:URL + "/_api/web/lists/getbytitle('DN_Producto')/Items?$select=ID&$filter=Folio eq '" + encodeURIComponent(folio) + "' and NoReporte eq '" + encodeURIComponent(reporte) + "'",
			type: "GET",
async: false,
			headers: {"accept": "application/json;odata=verbose"},
			success: function(data) {
				if(data.d.results) {
					for(var i = 0; i < data.d.results.length; i++) {
						$('#NumeroProducto').click();
					}
					for(var i = 0; i < data.d.results.length; i++) {
						obtenerProducto(data.d.results[i].ID, i + 1);
					}
				}
			},
			error: function (xhr) {
				alert('llenar Datos Producto ' + xhr.status + ': ' + xhr.statusText);
			}
		});
	}

	function obtenerProducto(identificador, campo) {
		$.ajax({
			url:URL + "/_api/web/lists/getbytitle('DN_Producto')/Items?$select= Producto,Cantidad,MontoUnitario,Total&$orderby=ID &$filter=ID eq '" + encodeURIComponent(identificador) + "'",
			type: "GET",
async: false,
			headers: {"accept": "application/json;odata=verbose"},
			success: function (data) {
				if (data.d.results) {
					$('#txtProducto' + campo).val(data.d.results[0].Producto);
					$('#txtCantidad' + campo).val(data.d.results[0].Cantidad);
					$('#txtMontoUnitario' + campo).val(data.d.results[0].MontoUnitario);
					$('#txtTotal' + campo).val(data.d.results[0].Total);
					if($.get('EDO') == 'Ver') {
						$('#txtProducto' + campo).prop('disabled', true);
						$('#txtCantidad' + campo).prop('disabled', true);
						$('#txtMontoUnitario' + campo).prop('disabled', true);
						$('#txtTotal' + campo).prop('disabled', true);
					}
				}
			},
			error: function (xhr) {
				alert('obtenerProducto ' + xhr.status + ': ' + xhr.statusText);
			}
		});
	}

	function llenarDatos(folio, reporte){
		$.ajax({
			url:URL + "/_api/web/lists/getbytitle('TR_Extravio')/Items?$select=ID&$filter=Title eq '" + encodeURIComponent(folio) + "' and NumeroReporte eq '" + encodeURIComponent(reporte) + "'",
			type: "GET",
async: false,
			headers: {"accept": "application/json;odata=verbose"},
			success: function(data) {
				if(data.d.results) {
					obtenerDatos(data.d.results[0].ID);
				}
			},
			error: function (xhr) {
				alert('llenarDato ' + xhr.status + ': ' + xhr.statusText);
			}
		});
	}

	function obtenerDatos(identificador) {
		$.ajax({
			url:URL + "/_api/web/lists/getbytitle('TR_Extravio')/Items?$select= HoraOcurre,HoraFinaliza,HoraReportanProteccion,NombrePersonaReportaProteccion,PuestoPersonaReportaProteccion,MontoRecuperacion,MontoProducto,MontoAproximadoProducto,MontoTotal,ObservacionesInformacionAdiciona,NombreReporte,NumeroReporte,Title&$orderby = ID &$filter=ID eq '" + encodeURIComponent(identificador) + "'",
			type: "GET",
async: false,
			headers: {"accept": "application/json;odata=verbose"},
			success: function (data) {
				if (data.d.results) {
					colocar(data.d.results[0]);
				}
			},
			error: function (xhr) {
				alert('obtenerDatos ' + xhr.status + ': ' + xhr.statusText);
			}
		});
	}

	function requestFailed(sender, args) {
		alert('Cannot get user account information: ' + args.get_message());
	}

	function bloquear(can_ubi, can_equi, can_per) {
		$('#txtHoraOcurre').prop('disabled', true);
		$('#txtHoraFinaliza').prop('disabled', true);
		$('#txtHoraAvisanProteccion').prop('disabled', true);
		$('#txtNombredelapersonaquereportaaproteccion').prop('disabled', true);
		$('#txtPuestodelapersonaquereportaaproteccion').prop('disabled', true);
		for(var i = 0; i <= can_equi; i++) {
			$('#txtNombrePersonasInvolucradas' + i).prop('disabled', true);
		}
		for(var i = 0; i <= can_equi; i++) {
			$('#txtAreaPersonasInvolucradas' + i).prop('disabled', true);
		}
		for(var i = 0; i <= can_equi; i++) {
			$('#txtNumeroEmpleadoPersonasInvolucradas' + i).prop('disabled', true);
		}
		for(var i = 0; i <= can_equi; i++) {
			$('#txtEmpresaPersonasInvolucradas' + i).prop('disabled', true);
		}
		for(var i = 0; i <= can_equi; i++) {
			$('#txtProducto' + i).prop('disabled', true);
		}
		for(var i = 0; i <= can_equi; i++) {
			$('#txtCantidad' + i).prop('disabled', true);
		}
		for(var i = 0; i <= can_equi; i++) {
			$('#txtMontoUnitario' + i).prop('disabled', true);
		}
		for(var i = 0; i <= can_equi; i++) {
			$('#txtTotal' + i).prop('disabled', true);
		}
		$('#txtMontodeRecuperacion').prop('disabled', true);
		$('#txtMontodelProducto').prop('disabled', true);
		$('#txtMontoAproximadoenproducto').prop('disabled', true);
		$('#tarObservacionesInformacionAdicional').prop('disabled', true);
		$('.bDinamico').prop('disabled', true);
	}

	function contarPersonasInvolucradas() {
		cont_PersonasInvolucradas++;
		$('#hdncontador_PersonasInvolucradas').val(cont_PersonasInvolucradas);
	}
	function contarProducto() {
		cont_Producto++;
		$('#hdncontador_Producto').val(cont_Producto);
	}

	function validarCampos() {
		if($('#txtHoraOcurre').val() === ''){
			$('#txtHoraOcurre').css('border-color', 'red');
	alert('No se puede continuar porque el campo * Hora en que ocurre está vacío');
			return false;
		}else{
			$('#txtHoraOcurre').css('border-color', '#D8D8D8');
		}
		if($('#txtHoraFinaliza').val() === ''){
			$('#txtHoraFinaliza').css('border-color', 'red');
	alert('No se puede continuar porque el campo * Hora en que finaliza está vacío');
			return false;
		}else{
			$('#txtHoraFinaliza').css('border-color', '#D8D8D8');
		}
		if($('#txtHoraAvisanProteccion').val() === ''){
			$('#txtHoraAvisanProteccion').css('border-color', 'red');
	alert('No se puede continuar porque el campo * Hora en que reportan a protección está vacío');
			return false;
		}else{
			$('#txtHoraAvisanProteccion').css('border-color', '#D8D8D8');
		}
		if($('#txtNombredelapersonaquereportaaproteccion').val() === ''){
			$('#txtNombredelapersonaquereportaaproteccion').css('border-color', 'red');
	alert('No se puede continuar porque el campo * Nombre de la persona que reporta a protección está vacío');
			return false;
		}else{
			$('#txtNombredelapersonaquereportaaproteccion').css('border-color', '#D8D8D8');
		}
		if($('#txtPuestodelapersonaquereportaaproteccion').val() === ''){
			$('#txtPuestodelapersonaquereportaaproteccion').css('border-color', 'red');
	alert('No se puede continuar porque el campo * Puesto de la persona que reporta a protección está vacío');
			return false;
		}else{
			$('#txtPuestodelapersonaquereportaaproteccion').css('border-color', '#D8D8D8');
		}
		for(var i = 1; i<= $('#hdncontador_PersonasInvolucradas').val(); i++){
			if($('#txtNombrePersonasInvolucradas' + i).val() === ''){
				$('#txtNombrePersonasInvolucradas' + i).css('border-color', 'red');
	alert('No se puede continuar porque el campo * Nombre(s) persona(s) involucrada(s) está vacío');
				return false;
			}else{
				$('#txtNombrePersonasInvolucradas' + i).css('border-color', '#D8D8D8');
			}
			if($('#txtAreaPersonasInvolucradas' + i).val() === ''){
				$('#txtAreaPersonasInvolucradas' + i).css('border-color', 'red');
	alert('No se puede continuar porque el campo * Área está vacío');
				return false;
			}else{
				$('#txtAreaPersonasInvolucradas' + i).css('border-color', '#D8D8D8');
			}
			if($('#txtNumeroEmpleadoPersonasInvolucradas' + i).val() === ''){
				$('#txtNumeroEmpleadoPersonasInvolucradas' + i).css('border-color', 'red');
	alert('No se puede continuar porque el campo * Número de empleado está vacío');
				return false;
			}else{
				$('#txtNumeroEmpleadoPersonasInvolucradas' + i).css('border-color', '#D8D8D8');
			}
			if($('#txtEmpresaPersonasInvolucradas' + i).val() === ''){
				$('#txtEmpresaPersonasInvolucradas' + i).css('border-color', 'red');
	alert('No se puede continuar porque el campo * Empresa está vacío');
				return false;
			}else{
				$('#txtEmpresaPersonasInvolucradas' + i).css('border-color', '#D8D8D8');
			}
		}
		for(var i = 1; i<= $('#hdncontador_Producto').val(); i++){
			if($('#txtProducto' + i).val() === ''){
				$('#txtProducto' + i).css('border-color', 'red');
	alert('No se puede continuar porque el campo * Producto está vacío');
				return false;
			}else{
				$('#txtProducto' + i).css('border-color', '#D8D8D8');
			}
			if($('#txtCantidad' + i).val() === ''){
				$('#txtCantidad' + i).css('border-color', 'red');
	alert('No se puede continuar porque el campo * Cantidad está vacío');
				return false;
			}else{
				$('#txtCantidad' + i).css('border-color', '#D8D8D8');
			}
			if($('#txtMontoUnitario' + i).val() === ''){
				$('#txtMontoUnitario' + i).css('border-color', 'red');
	alert('No se puede continuar porque el campo * Monto unitario está vacío');
				return false;
			}else{
				$('#txtMontoUnitario' + i).css('border-color', '#D8D8D8');
			}
			if($('#txtTotal' + i).val() === ''){
				$('#txtTotal' + i).css('border-color', 'red');
	alert('No se puede continuar porque el campo * Total está vacío');
				return false;
			}else{
				$('#txtTotal' + i).css('border-color', '#D8D8D8');
			}
		}
		if($('#txtMontodeRecuperacion').val() === ''){
			$('#txtMontodeRecuperacion').css('border-color', 'red');
	alert('No se puede continuar porque el campo * Monto de recuperación está vacío');
			return false;
		}else{
			$('#txtMontodeRecuperacion').css('border-color', '#D8D8D8');
		}
		if($('#txtMontodelProducto').val() === ''){
			$('#txtMontodelProducto').css('border-color', 'red');
	alert('No se puede continuar porque el campo * Monto del producto está vacío');
			return false;
		}else{
			$('#txtMontodelProducto').css('border-color', '#D8D8D8');
		}
		if($('#txtMontoAproximadoenproducto').val() === ''){
			$('#txtMontoAproximadoenproducto').css('border-color', 'red');
	alert('No se puede continuar porque el campo * Monto aproximado en producto está vacío');
			return false;
		}else{
			$('#txtMontoAproximadoenproducto').css('border-color', '#D8D8D8');
		}
		if($('#tarObservacionesInformacionAdicional').val() === ''){
			$('#tarObservacionesInformacionAdicional').css('border-color', 'red');
	alert('No se puede continuar porque el campo * Observaciones/Información adicional está vacío');
			return false;
		}else{
			$('#tarObservacionesInformacionAdicional').css('border-color', '#D8D8D8');
		}
		return true;
	}

	function obtener() {
		var datos = [];
		var e = {
			'HoraOcurre': $('#txtHoraOcurre').val(),
			'HoraFinaliza': $('#txtHoraFinaliza').val(),
			'HoraReportanProteccion': $('#txtHoraAvisanProteccion').val(),
			'NombrePersonaReportaProteccion': $('#txtNombredelapersonaquereportaaproteccion').val(),
			'PuestoPersonaReportaProteccion': $('#txtPuestodelapersonaquereportaaproteccion').val(),
			'MontoRecuperacion': $('#txtMontodeRecuperacion').val(),
			'MontoProducto': $('#txtMontodelProducto').val(),
			'MontoAproximadoProducto': $('#txtMontoAproximadoenproducto').val(),
			'ObservacionesInformacionAdiciona': $('#tarObservacionesInformacionAdicional').val(),
			'Identificador':$('#hdnidentificador').val(),
			'Estatus':$('#hdnestatus').val(),
			'NumeroReporte':$('#hdnnumero').val(),
			'NombreReporte':'ExtravioViaPublicaProducto'
		};
		var varPersonasInvolucradas = {};
		var varPersonasInvolucradass = [];
		for(var i = 1; i <= $('#hdncontador_PersonasInvolucradas').val(); i++) {
			if($('#txtNombrePersonasInvolucradas' + i).length){
				varPersonasInvolucradas.NombrePersona = $('#txtNombrePersonasInvolucradas' + i).val();
				varPersonasInvolucradas.Area = $('#txtAreaPersonasInvolucradas' + i).val();
				varPersonasInvolucradas.NoEmpleado = $('#txtNumeroEmpleadoPersonasInvolucradas' + i).val();
				varPersonasInvolucradas.Empresa = $('#txtEmpresaPersonasInvolucradas' + i).val();
				varPersonasInvolucradass.push(JSON.stringify(varPersonasInvolucradas));
			}
		}
		var varProducto = {};
		var varProductos = [];
		for(var i = 1; i <= $('#hdncontador_Producto').val(); i++) {
			if($('#txtProducto' + i).length){
				varProducto.Producto = $('#txtProducto' + i).val();
				varProducto.Cantidad = $('#txtCantidad' + i).val();
				varProducto.MontoUnitario = $('#txtMontoUnitario' + i).val();
				varProducto.Total = $('#txtTotal' + i).val();
				varProductos.push(JSON.stringify(varProducto));
			}
		}
		datos.push(JSON.stringify(e));
		datos.push(varPersonasInvolucradass);
		datos.push(varProductos);
		return datos;
	}

	function colocar(datos) {
		$('#txtHoraOcurre').val(datos.HoraOcurre),
		$('#txtHoraFinaliza').val(datos.HoraFinaliza),
		$('#txtHoraAvisanProteccion').val(datos.HoraReportanProteccion),
		$('#txtNombredelapersonaquereportaaproteccion').val(datos.NombrePersonaReportaProteccion),
		$('#txtPuestodelapersonaquereportaaproteccion').val(datos.PuestoPersonaReportaProteccion),
		$('#txtMontodeRecuperacion').val(datos.MontoRecuperacion),
		$('#txtMontodelProducto').val(datos.MontoProducto),
		$('#txtMontoAproximadoenproducto').val(datos.MontoAproximadoProducto),
		$('#tarObservacionesInformacionAdicional').val(datos.ObservacionesInformacionAdiciona),
		$('#hdnidenficador').val(datos.Title),
		$('#hdnstatus').val(datos.Estatus),
		$('#hdnnuevo').val(datos.Nuevo),
		$('#hdnnumero').val(datos.NumeroReporte)
	}


	function DuplicarGrupo(claseDuplicados, elementChild) {
	    padreBoton = elementChild.parentNode;
	    padrePadreBoton = padreBoton.parentNode;
	    padrePadrePadreBoton = padrePadreBoton.parentNode;
	    padrePadrePadrePadreBoton = padrePadrePadreBoton.parentNode;
	    nombrePadre = padrePadrePadrePadreBoton.id;
	    
	    listaReportes = document.getElementsByClassName("BloqueReportesDinamicos");
	    for (i = 0; i < listaReportes.length; i++) {
	        if (listaReportes[i].id == nombrePadre) {
	            var totalListaDuplicacion = listaReportes[i].getElementsByClassName(claseDuplicados).length;
	            var listaDuplicacion = listaReportes[i].getElementsByClassName(claseDuplicados)[0];
	            break;
	        }
	    }
	
	    elementosDuplicar = listaDuplicacion.getElementsByTagName("div");
	    padreAnexar = listaDuplicacion.parentNode;
	
	    //contenedor de bloque
	    var divfinalcontenedor = document.createElement("div");
	    divfinalcontenedor.setAttribute("class", elementosDuplicar[0].className);
	
	    //contenedor clase
	    var divfinalcontenedorclase = document.createElement("div");
	    divfinalcontenedorclase.setAttribute("class", listaDuplicacion.className);
	    divfinalcontenedorclase.setAttribute("id", totalListaDuplicacion);
	
	    var inputeliminar = document.createElement("input");
	    inputeliminar.type = "button";
	    inputeliminar.setAttribute("onclick", 'EliminarBloqueDuplicacion(this);');
	    inputeliminar.setAttribute("class", 'bDinamico');
	    inputeliminar.value = "X";
	
	    divfinalcontenedorclase.appendChild(inputeliminar);
	    
	
	    for (i = 1; i < elementosDuplicar.length; i++) {
	        elementlabel = elementosDuplicar[i].getElementsByTagName("label")[0];
			elementText = elementosDuplicar[i].getElementsByClassName("text")[0];
			elementDate = elementosDuplicar[i].getElementsByClassName("date")[0];
			elementTime = elementosDuplicar[i].getElementsByClassName("time")[0];
			elementNumero = elementosDuplicar[i].getElementsByClassName("numero")[0];
			elementoMoneda = elementosDuplicar[i].getElementsByClassName("moneda")[0];
			elementoArea = elementosDuplicar[i].getElementsByClassName("area")[0];
			elementoSelect = elementosDuplicar[i].getElementsByClassName("select")[0];
			
			
		var divfinal1 = document.createElement("div");
		divfinal1.setAttribute("class", elementosDuplicar[i].className);
	
	
			if(elementText === undefined || elementText === null) {
				if(elementNumero === undefined || elementNumero === null) {
					if(elementoMoneda === undefined || elementoMoneda === null) {
						if(elementoArea === undefined || elementoArea === null) {
							if(elementoSelect === undefined || elementoSelect === null) {
								if(elementDate === undefined || elementDate === null) {
									if(elementTime === undefined || elementTime === null) {
									}
									else {
									
										console.log('Tiempo');
				                        var lblt = document.createElement('label');
				                        lblt.setAttribute("id", "lbl"+ elementTime .id + totalListaDuplicacion);
				                        lblt.innerHTML = elementlabel.innerHTML;
									
										var divbt = document.createElement('div');
										divbt.setAttribute("id", "div" + elementTime .id + totalListaDuplicacion);
										divbt.setAttribute("class", "input-group time");	
										
					                    var txbt = document.createElement('input');
				                        txbt.type = "text";
				                        txbt.setAttribute("id", "txt" + elementTime .id + totalListaDuplicacion);
				                        txbt.setAttribute("class", "form-control");
				                        
				                        var spbt = document.createElement('span');
				                        spbt.setAttribute("class", "input-group-addon");
		
				                        var spbtb = document.createElement('span');
				                        spbtb.setAttribute("class", "glyphicon glyphicon-time");
				                        spbt.appendChild(spbtb);
				                        
				                        divbt.appendChild(txbt);
				                        divbt.appendChild(spbt);
				                        
				                        divfinal1.appendChild(lblt);
					                    divfinal1.appendChild(divbt);	
				                    }		
				                }					
								else {								
									console.log('Fecha');
			                        var lblf = document.createElement('label');
			                        lblf.setAttribute("id", "lbl"+ elementDate .id + totalListaDuplicacion);
			                        lblf.innerHTML = elementlabel.innerHTML;
								
									var divbf = document.createElement('div');
									divbf.setAttribute("id", "div" + elementDate .id + totalListaDuplicacion);
									divbf.setAttribute("class", "input-group date");	
									
				                    var txbf = document.createElement('input');
			                        txbf.type = "text";
			                        txbf.setAttribute("id", "txt" + elementDate .id + totalListaDuplicacion);
			                        txbf.setAttribute("class", "form-control");
			                        
			                        var spbf = document.createElement('span');
			                        spbf.setAttribute("class", "input-group-addon");
	
			                        var spbfb = document.createElement('span');
			                        spbfb.setAttribute("class", "glyphicon glyphicon-time");
			                        spbf.appendChild(spbfb);
			                        
			                        divbf.appendChild(txbf);
			                        divbf.appendChild(spbf);
			                        
			                        divfinal1.appendChild(lblf);
				                    divfinal1.appendChild(divbf);									
								}								
							}
							else {
								console.log('Select');
		                        var lbl1 = document.createElement('label');
		                        lbl1.setAttribute("id", "lbl"+ elementoSelect.id + totalListaDuplicacion);
		                        lbl1.innerHTML = elementlabel.innerHTML;
	
		                        var txb1 = document.createElement('select');
		                        /*
		                        for(c=0;c<elementoSelect.options.length;c++){
		                        	var ops = document.createElement('option');
		                        	ops.value = elementoSelect.options[c].value;
		                        	ops.text = elementoSelect.options[c].text;
		                        	txb1.appendChild(ops);
		                        }
		                        */
		                        txb1.setAttribute("id", elementoSelect.id + totalListaDuplicacion);
		                        txb1.setAttribute("class", elementoSelect.className);
		                        llenarObjSelect(txb1);

			                    divfinal1.appendChild(lbl1);
			                    divfinal1.appendChild(txb1);
		                        
							}
	                    }
	                    else {
							console.log('Text Area');
							var lbl1 = document.createElement('label');
	                        lbl1.setAttribute("id", "lbl"+ elementoArea .id + totalListaDuplicacion);
	                        lbl1.innerHTML = elementlabel.innerHTML;
	
	                        var txb1 = document.createElement('textarea');
	                        txb1.setAttribute("id", elementoArea .id + totalListaDuplicacion);
							txb1.setAttribute("maxlength", elementoArea .maxLength);
	                        txb1.setAttribute("class", elementoArea .className);
	                        
		                    divfinal1.appendChild(lbl1);
		                    divfinal1.appendChild(txb1);
	                        
	                    }
					}
					else {
						console.log('Moneda');							
						var lbl1 = document.createElement('label');
	                    lbl1.setAttribute("id", "lbl"+elementoMoneda .id + totalListaDuplicacion);
	                    lbl1.innerHTML = elementlabel.innerHTML;
	
	                    var txb1 = document.createElement('input');
	                    txb1.type = "text";
	                    txb1.setAttribute("id", elementoMoneda .id + totalListaDuplicacion);
	                    txb1.setAttribute("maxlength", elementoMoneda .maxlength);
	                    txb1.setAttribute("class", elementoMoneda .className);
	                    
	                    divfinal1.appendChild(lbl1);
	                    divfinal1.appendChild(txb1);
	                    
	                }
				}
				else {
					console.log('Numero');						
					var lbl1 = document.createElement('label');
	                lbl1.setAttribute("id", "lbl"+elementNumero .id + totalListaDuplicacion);
	                lbl1.innerHTML = elementlabel.innerHTML;
	
	                var txb1 = document.createElement('input');
	                txb1.type = "text";
	                txb1.setAttribute("id", elementNumero .id + totalListaDuplicacion);
	                txb1.setAttribute("maxlength", elementNumero .maxLength);
	                txb1.setAttribute("class", elementNumero .className);
	                
	                divfinal1.appendChild(lbl1);
	                divfinal1.appendChild(txb1);
	                
				}
			}
			else {
				console.log('Texto');	
				var lbl1 = document.createElement('label');
	            lbl1.setAttribute("id", "lbl"+elementText .id + totalListaDuplicacion);
	            lbl1.innerHTML = elementlabel.innerHTML;
	
	            var txb1 = document.createElement('input');
	            txb1.type = "text";
	            txb1.setAttribute("id", elementText .id + totalListaDuplicacion);
	            txb1.setAttribute("maxlength", elementText.maxLength);
	            txb1.setAttribute("class", elementText.className);
	            
	            divfinal1.appendChild(lbl1);
	            divfinal1.appendChild(txb1);
	
			}	
	        divfinalcontenedor.appendChild(divfinal1);
	    }	    
		console.log('cierra grupo');  	   
	    divfinalcontenedorclase.appendChild(divfinalcontenedor);
	    padreAnexar.appendChild(divfinalcontenedorclase);

		console.log('aplica jqueries');  	   	    

		$('.fecha').inputmask('datetime', {inputFormat:'dd/mm/yyyy'});
		$('.tiempo').inputmask('datetime', {inputFormat:'HH:MM'});
		$('.moneda').inputmask('currency');
		$('.numero').inputmask('numeric');
		
			$( "input[id^='txtCantidad']" ).blur(function() {
			$("input[id^='txtCantidad']").each(function( index ) {
				var numId = $(this).attr("id").substring(11, $(this).attr("id").length);
				var cantidad = $(this).val();
				var montoUnitario = $("#txtMontoUnitario" + numId).val();
				
				if(montoUnitario != '')
				{
					var resultado = cantidad * parseFloat(montoUnitario.replace('$ ','').replace(new RegExp(',', 'g'), ''));  
					
					$("#txtTotal" + numId).val(resultado);
					
				}
				
			});	
			
			var suma = 0;
			$("input[id^='txtTotal']").each(function( index ) {
				
				if($(this).val() != '')
				 	suma += parseFloat($(this).val().replace('$ ','').replace(new RegExp(',', 'g'), ''));
 
			});	
			
			
			$("#txtMontoAproximadoenproducto").val(suma);
			sumarMonto();
		
		});
		
		$( "input[id^='txtMontoUnitario']" ).blur(function() {
			$("input[id^='txtCantidad']").each(function( index ) {
				var numId = $(this).attr("id").substring(11, $(this).attr("id").length);
				var cantidad = $(this).val();
				var montoUnitario = $("#txtMontoUnitario" + numId).val();
				
				if(montoUnitario != '')
				{
					var resultado = cantidad * parseFloat(montoUnitario.replace('$ ','').replace(new RegExp(',', 'g'), ''));  
					
					$("#txtTotal" + numId).val(resultado);
					
				}
			});		
			
			var suma = 0;
			$("input[id^='txtTotal']").each(function( index ) {
				
				if($(this).val() != '')
				 	suma += parseFloat($(this).val().replace('$ ','').replace(new RegExp(',', 'g'), ''));
 
			});	
			
			
			$("#txtMontoAproximadoenproducto").val(suma);		
			sumarMonto();
		});
		
				
		$("input[id^='txtTotal']").each(function( index ) {
			$(this).prop( "disabled", true );
		});	


	    return;	    
	}

	function EliminarBloqueDuplicacion(element) {
		//console.log(element.id);
        elementParent = element.parentNode;
        elementParent.parentNode.removeChild(elementParent);
    }

	//Función llenar los selects
	function llenarObjSelect(objCombo, selectValue)
	{
		var cuenta = personProperties.get_accountName().split('|')[2];
		pais = obtenerPaisUsuario(cuenta);
		console.log(pais);

		console.log('objCombo.id = ' + objCombo.id);
		var stnames = objCombo.id.split('_');		
		console.log(stnames);
		var lstname = stnames[0];
		console.log(lstname);
		//console.log(objCombo, combo);
		var optionx = document.createElement("option");
		optionx.text = "...";
		optionx.value = null;
		objCombo.add(optionx);

		$.ajax({ 
			url: URL + "/_api/web/lists/getbytitle('" + lstname + "')/Items?$select=Title&$filter=Pa_x00ed_s eq '" + encodeURIComponent(pais) + "'",  
			type: "GET", 
			headers: {"accept": "application/json;odata=verbose"}, 
			success: function (data) 
			{
				if (data.d.results.length > 0) 
				{
					for (i = 0; i < data.d.results.length; i++) 
					{
		  				optionx = document.createElement("option");
		  				optionx.text = data.d.results[i].Title;
		  				optionx.value = data.d.results[i].Title;
		  				objCombo.add(optionx);
		 			}
		 			console.log("Seleccionando elemento: " +selectValue);
		 			$('#'+objCombo.id).val(selectValue);

				}
			}, 
			error: function (xhr) 
			{ 
				console.log(xhr.status + ': ' + xhr.statusText);
			} 
		}); 
	}
    function onExitoCargaEstados(sender, args) 
    {
        try 
        {
            var listItemEnumerator = this.collListItemEstados.getEnumerator();

            // Borra las opciones previas
            var myselect = document.getElementById("dtlEstado");

            while (listItemEnumerator.moveNext()) 
            {		
                        var existe = false;
                var oListItem = listItemEnumerator.get_current();

                if(oListItem.get_item('ClavePais').toUpperCase() != pais.toUpperCase())
                    continue;
                
                var txt = oListItem.get_item('NombreEstado');
                for(i = 0; i < myselect.options.length; i++)
                {
                	if(myselect.options[i].value == txt)
	                {
	                	existe = true;	                
	                }
                }
                if(existe)
                continue;
                newoption = document.createElement("option");
                newoption.text = txt;
                newoption.value = txt;
                myselect.appendChild(newoption);
            }
        }
        catch (e) 
        {
            console.log('onExitoCargaEstados', e);
        }
    }

    function onExitoCargaMun(sender, args) {
        try {
            var listItemEnumerator = this.collListItemMun.getEnumerator();

            // Borra las opciones previas
            var myselect = document.getElementById("dtlMun");
			var selected = document.getElementById("dtlEstado");
			console.log(selected);
			var tselected = document.getElementById("txtEstado");
			console.log(tselected.value);
            while (listItemEnumerator.moveNext()) 
            {		
                var oListItem = listItemEnumerator.get_current();
                if(oListItem.get_item('ClavePais').toUpperCase() != pais.toUpperCase())
                    continue;
                    
                newoption = document.createElement("option");
                newoption.text = oListItem.get_item('NombreMunicipio');
                newoption.value = oListItem.get_item('NombreMunicipio');
                myselect.appendChild(newoption);
            }
        }
        catch (e) {
            console.log('onExitoCargaMun', e);
        }
    }

    function onCargaError(sender, args) {
        console.log('Request failed. ' + args.get_message() + '\n' + args.get_stackTrace());
    }

    function getEstados()
   	{
		var URL = "https://cocacolafemsa.sharepoint.com/sites/SWPP";   	
		var clientContext = new SP.ClientContext(URL);
		var oListEstados = clientContext.get_web().get_lists().getByTitle('LstUbicacionEstado');
		
		var camlQuery = new SP.CamlQuery();
		camlQuery.set_viewXml('');
		this.collListItemEstados = oListEstados.getItems(camlQuery);
		
		clientContext.load(this.collListItemEstados);
		clientContext.executeQueryAsync(Function.createDelegate(this, this.onExitoCargaEstados), Function.createDelegate(this, this.onCargaError));
   	}
	function getMun()
	{
		var URL = "https://cocacolafemsa.sharepoint.com/sites/SWPP";        
        var clientContextMun = new SP.ClientContext(URL);
        var oListMun = clientContextMun.get_web().get_lists().getByTitle('LstUbicacionMunicipio');
        
        var camlQueryMun = new SP.CamlQuery();
        camlQueryMun.set_viewXml('');
        this.collListItemMun = oListMun.getItems(camlQueryMun);

        clientContextMun.load(this.collListItemMun);
        clientContextMun.executeQueryAsync(Function.createDelegate(this, this.onExitoCargaMun), Function.createDelegate(this, this.onCargaError));
	}
	function getLugarTraslado()
	{
		var txt = document.getElementById('txtLugardeTraslado');
		var ops = $('#LstOcupaTraslado_ option:selected').text();
		if(ops.toUpperCase() != 'SI')
			txt.style.visibility = 'hidden';
		else
			txt.style.visibility = 'visible';
	}
	function getLugarTraslado2(opc)
	{
		console.log('entro lugartraslado');
		var txt = document.getElementById('txtLugardeTraslado');
		console.log(opc.toUpperCase());
		if(opc.toUpperCase() != 'SI')
			txt.style.visibility = 'hidden';
		else
			txt.style.visibility = 'visible';
	}

var SelectedItem;


	function sumarMonto ()
	{
	    var resultado="";
	    var montodeRecuperacion = document.getElementById('txtMontodeRecuperacion').value;
   	    var montoAproximadodelProducto = document.getElementById('txtMontoAproximadoenproducto').value;	    
	    var montodelProducto = document.getElementById('txtMontodelProducto').value;	   
	    		 	
		var tmontoderecuperacion= 0;
		if(montodeRecuperacion != '')
		 	tmontoderecuperacion= parseFloat(montodeRecuperacion.replace('$ ','').replace(new RegExp(',', 'g'), ''));
		 	//tmontoderecuperacion= parseFloat(montodeRecuperacion.replace('$ ','').replace(',',''));
		 	
		 var tmontodelProducto= 0;
		if(montodelProducto != '')
			tmontodelProducto= parseFloat(montodelProducto.replace('$ ','').replace(new RegExp(',', 'g'), ''));
		 	//totrosmontos= parseFloat(otrosMontos.replace('$ ','').replace(',',''));
		 	
		 var toAproximadodelProducto= 0;
		if(montoAproximadodelProducto != '')
			toAproximadodelProducto = parseFloat(montoAproximadodelProducto.replace('$ ','').replace(new RegExp(',', 'g'), ''));
		 	//totrosmontos= parseFloat(otrosMontos.replace('$ ','').replace(',',''));
		 	
	    resultado= tmontoderecuperacion + tmontodelProducto + toAproximadodelProducto;
	    //alert(resultado);
	    document.getElementById('txtAcumulacionMonto').value = resultado;
		
	}



</script>
</head>
<body>
	<div id="ReportesDinamicos" class="container">
		<div id="Reporte_2" class="BloqueReportesDinamicos">
<h3 id="lblExtravío/Vía Pública/Producto">Extravío/Vía Pública/Producto</h3>
	<div id="ctHoraEvento" class='container'>
		<div class='col-xs-12 col-sm-12 col-md-12 col-lg-12'>
			<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
				<label  id='lblHoraOcurre'>* Hora en que ocurre</label>
				<div class='input-group time' id='HoraOcurre'>
					<input type='text' class='form-control' id="txtHoraOcurre"/>
					<span class='input-group-addon'>
						<span class='glyphicon glyphicon-time'></span>
					</span>
				</div>
			</div>
			<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
				<label  id='lblHoraFinaliza'>* Hora en que finaliza</label>
				<div class='input-group time' id='HoraFinaliza'>
					<input type='text' class='form-control' id="txtHoraFinaliza"/>
					<span class='input-group-addon'>
						<span class='glyphicon glyphicon-time'></span>
					</span>
				</div>
			</div>
		</div>
	</div>
	<div id="ctHoraEvento" class='container'>
		<div class='col-xs-12 col-sm-12 col-md-12 col-lg-12'>
			<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
				<label  id='lblHoraAvisanProteccion'>* Hora en que reportan a protección</label>
				<div class='input-group time' id='HoraAvisanProteccion'>
					<input type='text' class='form-control' id="txtHoraAvisanProteccion"/>
					<span class='input-group-addon'>
						<span class='glyphicon glyphicon-time'></span>
					</span>
				</div>
			</div>
			<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
				<label class='control-label' id= 'lblNombredelapersonaquereportaaproteccion'  >* Nombre de la persona que reporta a protección</label>
				<input class='form-control' idvariabledepende ='Nombredelapersonaquereportaaproteccion' maxlength='50' id='txtNombredelapersonaquereportaaproteccion' type='text'  />
			</div>
			<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
				<label class='control-label' id= 'lblPuestodelapersonaquereportaaproteccion'  >* Puesto de la persona que reporta a protección</label>
				<input class='form-control' idvariabledepende ='Puestodelapersonaquereportaaproteccion' maxlength='50' id='txtPuestodelapersonaquereportaaproteccion' type='text'  />
			</div>
		</div>
	</div>
	<div id="PersonasInvolucradas" class='container'>
		<div class='col-xs-12 col-lg-12 col-md-12 col-xl-12'>
			<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group' unselectable='on'>
				<input type='button' class="bDinamico" onclick='javascript:DuplicarGrupo("DPersonasInvolucradas", this);' id='NumeroPersonasInvolucradas' value='Agregar personas involucradas'/>
			</div>
		</div>
	</div>
	<section class="PersonasInvolucradasD">
		<div class='container DPersonasInvolucradas' style="visibility:hidden; display:none">
			<div class='col-xs-12 col-lg-12 col-md-12 col-xl-12'>

	<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
		<label class='control-label' id= 'lblNombrePersonasInvolucradas'  >* Nombre(s) persona(s) involucrada(s)</label>
		<input class='form-control text' idvariabledepende ='NombrePersonasInvolucradas' maxlength='50' id='txtNombrePersonasInvolucradas' type='text'  />
	</div>

	<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
		<label class='control-label' id= 'lblAreaPersonasInvolucradas'  >* Área</label>
		<input class='form-control text' idvariabledepende ='AreaPersonasInvolucradas' maxlength='50' id='txtAreaPersonasInvolucradas' type='text'  />
	</div>

	<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
		<label class='control-label' id= 'lblNumeroEmpleadoPersonasInvolucradas'  >* Número de empleado</label>
		<input class='form-control text' idvariabledepende ='NumeroEmpleadoPersonasInvolucradas' maxlength='8' id='txtNumeroEmpleadoPersonasInvolucradas' type='text'  />
	</div>

	<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
		<label class='control-label' id= 'lblEmpresaPersonasInvolucradas'  >* Empresa</label>
		<input class='form-control text' idvariabledepende ='EmpresaPersonasInvolucradas' maxlength='50' id='txtEmpresaPersonasInvolucradas' type='text'  />
	</div>
			</div>
		</div>
	</section>
	<div id="Producto" class='container'>
		<div class='col-xs-12 col-lg-12 col-md-12 col-xl-12'>
			<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group' unselectable='on'>
				<input type='button' class="bDinamico" onclick='javascript:DuplicarGrupo("DProducto", this);' id='NumeroProducto' value='Agregar productos'/>
			</div>
		</div>
	</div>
	<section class="ProductoD">
		<div class='container DProducto' style="visibility:hidden; display:none">
			<div class='col-xs-12 col-lg-12 col-md-12 col-xl-12'>

	<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
		<label class='control-label' id= 'lblProducto'  >* Producto</label>
		<input class='form-control text' idvariabledepende ='Producto' maxlength='50' id='txtProducto' type='text'  />
	</div>

	<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
		<label class='control-label' id= 'lblCantidad'  >* Cantidad</label>
		<input class='form-control numero' idvariabledepende ='Cantidad' maxlength='25' id='txtCantidad' type='text'  />
	</div>

	<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
		<label class='control-label' id= 'lblMontoUnitario'  >* Monto unitario</label>
		<input class='form-control moneda' idvariabledepende ='MontoUnitario' maxlength='25' id='txtMontoUnitario' type='text'  />
	</div>

	<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
		<label class='control-label' id= 'lblTotal'  >* Total</label>
		<input class='form-control moneda' idvariabledepende ='Total' maxlength='25' id='txtTotal' type='text'  />
	</div>
			</div>
		</div>
	</section>
	<div id="ctHoraEvento" class='container'>
		<div class='col-xs-12 col-sm-12 col-md-12 col-lg-12'>
			<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
				<label class='control-label' id= 'lblMontodeRecuperacion'  >* Monto de recuperación</label>
				<input class='form-control moneda' onblur="sumarMonto()" idvariabledepende ='MontodeRecuperacion' maxlength='25' id='txtMontodeRecuperacion' type='text'  />
			</div>
			<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
				<label class='control-label' id= 'lblMontodelProducto'  >* Monto del producto</label>
				<input class='form-control moneda' onblur="sumarMonto()" idvariabledepende ='MontodelProducto' maxlength='25' id='txtMontodelProducto' type='text'  />
			</div>
			<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
				<label class='control-label' id= 'lblMontoAproximadoenproducto'  >* Monto aproximado en producto</label>
				<input class='form-control moneda' onblur="sumarMonto()" idvariabledepende ='MontoAproximadoenproducto' maxlength='25' id='txtMontoAproximadoenproducto' type='text'  disabled/>
			</div>
		</div>
	</div>
	<div id="ctHoraEvento" class='container'>
		<div class='col-xs-12 col-sm-12 col-md-12 col-lg-12'>
			<div class='col-xs-6 col-md-4 col-lg-3 col-xl-3 form-group'>
				<label class='control-label' id= 'lblAcumulacionMonto'>* Monto total</label>
				<input class='form-control moneda' idvariabledepende ='MontoTotal' maxlength='25' id='txtAcumulacionMonto' type='text' disabled/>
			</div>
		</div>
	</div>

	<div id="ctHoraEvento" class='container'>
		<div class='col-xs-12 col-sm-12 col-md-12 col-lg-12'>
			<div class='col-xs-12 col-md-12 col-lg-12 col-xl-12 form-group'>
				<label class='obligatorio etiquetaM control-label'  >* Observaciones/Información adicional</label>
				<textarea maxlength='5000' id='tarObservacionesInformacionAdicional' class='form-control' rows='5'  ></textarea>
			</div>
		</div>
	</div>

			<input type='button' id='btnAgregar' value='Agregar'/>
		</div>
	</div>
	<input type="hidden" id="hdnidentificador" value=""/>
	<input type="hidden" id="hdnnumero" value=""/>
	<input type="hidden" id="hdnestatus" value="Espera"/>
	<input type="hidden" id="hdngua" value="true"/>
	<input type="hidden" id="hdncontador_PersonasInvolucradas" value="0"/>
	<input type="hidden" id="hdncontador_Producto" value="0"/>
	<span id="lblCamposFaltantes" style="display:none">Faltan campos por llenar</span>
	<span id="lblAgregarExito" style="display:none">El reporte se ha agregado con éxito</span>
	<span id="lblAgregarAviso" style="display:none">El reporte capturado se va a agregar el reporte principal</span>
</body>
</html>
