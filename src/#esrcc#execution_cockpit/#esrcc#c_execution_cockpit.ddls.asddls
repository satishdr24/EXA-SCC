@EndUserText.label: 'Execution Cockpit'
@ObjectModel.query.implementedBy : 'ABAP:/ESRCC/CL_C_EXECUTIONCOCKPIT'
@AbapCatalog.extensibility.extensible: true
@Metadata.allowExtensions: true
define root custom entity /ESRCC/C_EXECUTION_COCKPIT
{
      @UI.lineItem           : [{ position: 10, hidden: true}]
      @UI.hidden             : true
  key sysid                  : /esrcc/sysid;
   
      @UI.lineItem           : [{ position: 11, hidden: true }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_RYEAR', element: 'ryear' }}]
      @UI.selectionField     : [{ position: 5 }]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
  key ryear                  : /esrcc/ryear;
      
      @UI.lineItem           : [{ position: 15, hidden: true }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_POPER', element: 'Poper' }}]
      @UI.selectionField     : [{ position: 10 }]
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.filter.mandatory: true
  key poper                  : /esrcc/poper;

      @UI.lineItem           : [{ position: 10 }]
      @UI.hidden             : true
  key nodeid                 : abap.char(100);

      @UI.lineItem           : [{ position: 40, hidden: true }]
      @UI.selectionField     : [{ position: 20 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_LegalEntity_F4', element: 'Legalentity' } }]
      @ObjectModel.text.element: [ 'legalentitydescription' ]
      @UI.textArrangement    : #TEXT_LAST
  key Legalentity            : /esrcc/legalentity;

      @UI.lineItem           : [{ position: 41, hidden: true  }]
      @UI.selectionField     : [{ position: 30 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COMPANYCODES_PR_F4', element: 'Ccode' } }]
//                                       additionalBinding: [{ element: 'Legalentity', localElement: 'Legalentity' }] }]
      @ObjectModel.text.element: [ 'ccodedescription' ]
      @UI.textArrangement    : #TEXT_LAST
  key ccode                  : /esrcc/ccode_de;

      @UI.lineItem           : [{ position: 42, hidden: true  }]

      @UI.selectionField     : [{ position: 40  }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTOBJECTS', element: 'Costobject' }}]
      @ObjectModel.text.element: [ 'costobjectdescription' ]
      @UI.textArrangement    : #TEXT_LAST
  key Costobject             : /esrcc/costobject_de;

      @UI.lineItem           : [{ position: 50, hidden: true  }]
      @UI.selectionField     : [{ position: 50 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSCEN_F4', element: 'Costcenter' }}]
//                                            additionalBinding: [{ element: 'Costobject', localElement: 'Costobject'}]}]
      @ObjectModel.text.element: [ 'costcenterdescription' ]
      @UI.textArrangement    : #TEXT_LAST
  key Costcenter             : /esrcc/costcenter;

      @UI.lineItem           : [{ position: 60, hidden: true  }]
      @UI.selectionField     : [{ position: 60 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_SERVICEPRODUCT_F4', element: 'ServiceProduct' }}]
//                                          additionalBinding: [{ element: 'OECD', localElement: 'oecd' }] }]
      @ObjectModel.text.element: [ 'serviceproductdescr' ]
      @UI.textArrangement    : #TEXT_LAST
  key ServiceProduct         : /esrcc/srvproduct;
   
      @UI.lineItem           : [{ position: 50, hidden: true  }]
      @UI.selectionField     : [{ position: 55 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_OECD', element: 'OECD' }}]
      @UI.textArrangement    : #TEXT_LAST
      oecd                   : /esrcc/oecdtpg_de;
      
      @UI.selectionField     : [{ position: 90 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_TPPROFILE', element: 'TpProfile' }}]
      @UI.textArrangement    : #TEXT_LAST
      tpprofile              : /esrcc/tpprofile;
      
//      @UI.selectionField     : [{ position: 90 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_PROFITCENTER_F4', element: 'ProfitCenter' }}]
      @UI.textArrangement    : #TEXT_LAST
      ProfitCenter           : /esrcc/profit_center;
      
//      @UI.selectionField     : [{ position: 90 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_FunctionalArea_F4', element: 'FunctionalArea' }}]
      @UI.textArrangement    : #TEXT_LAST
      FunctionalArea         : /esrcc/functional_area;
      
//      @UI.selectionField     : [{ position: 90 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_BUSINESSDIV_F4', element: 'BusinessDivision' }}]
      @UI.textArrangement    : #TEXT_LAST
      BusinessDivision       : /esrcc/businessdivision;
   
      @UI.lineItem           : [{ position: 70, criticality: 'StdChargeoutcriticallity', criticalityRepresentation: #WITHOUT_ICON }]
      @EndUserText.label     : 'Cost Base & Stewardship'
      @ObjectModel.text.element: [ 'StdChargeoutstatusdescr' ]
      @UI.textArrangement    : #TEXT_ONLY
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_EXECSTATUS', element: 'Status' } }]
      @UI.hidden             : true
      StdChargeout_Status    : /esrcc/process_status_de;

      @UI.lineItem           : [{ position: 80, criticality: 'Recalculationcriticallity', criticalityRepresentation: #WITHOUT_ICON  }]
      @EndUserText.label     : 'Service Cost Share & Markup'
      @ObjectModel.text.element: [ 'Recalculationstatusdescr' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_EXECSTATUS', element: 'Status' } }]
      @UI.textArrangement    : #TEXT_ONLY
      @UI.hidden             : true
      Recalculation_Status     : /esrcc/process_status_de;

//      @UI.lineItem           : [{ position: 90, criticality: 'chargeoutcriticality', criticalityRepresentation: #WITHOUT_ICON  }]
      @EndUserText.label     : 'Forecast Charge-out'
      @ObjectModel.text.element: [ 'forecaststatusdescr' ]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_EXECSTATUS', element: 'Status' } }]
      @UI.textArrangement    : #TEXT_ONLY
      @UI.hidden             : true
      Forecast_status       : /esrcc/process_status_de;

      @UI.lineItem           : [{ position: 100, hidden: true }]
      @EndUserText.label     : 'year end adjustment'
      @UI.hidden             : true
      ye_status              : /esrcc/process_status_de;

      @UI.hidden             : true
      legalentitydescription : /esrcc/description;
      @UI.hidden             : true
      ccodedescription       : /esrcc/description;
      @UI.hidden             : true
      costobjectdescription  : /esrcc/description;
      @UI.hidden             : true
      costcenterdescription  : /esrcc/description;
      @UI.hidden             : true
      serviceproductdescr    : /esrcc/description;
      @UI.hidden             : true
      StdChargeoutstatusdescr    : /esrcc/status_description;
      @UI.hidden             : true
      Recalculationstatusdescr : /esrcc/status_description;
      @UI.hidden             : true
      forecaststatusdescr    : /esrcc/status_description;
      @UI.hidden             : true
      legalcountry           : land1;
      @UI.hidden             : true
      StdChargeoutcriticallity   : abap.char(1);
      @UI.hidden             : true
      Recalculationcriticallity : abap.char(1);
      @UI.hidden             : true
      Forecastcriticallity   : abap.char(1);
      @UI.hidden             : true
      parentnodeid           : abap.char(100);
      @UI.hidden             : true
      HierarchyLevel         : abap.numc(1);
      @UI.hidden             : true
      Drillstate             : abap.char(20);
      @UI.hidden             : true
      description            : abap.char(256);
      @UI.hidden             : true
      selectionallowed       : abap_boolean;
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_EXECUTIONACTIONS', element: 'Action' }}]
      @Consumption.filter.hidden: true
      @UI.textArrangement    : #TEXT_ONLY
      @UI.selectionField     : [{ position: 70 }]
      @Consumption.filter.selectionType: #SINGLE
      action                 : /esrcc/actions;
      @UI.hidden             : true
      messagestdchargeout      : abap.char( 225 );
      @UI.hidden             : true
      messagerecalculation         : abap.char( 225 );
      @UI.hidden             : true
      messageforecast        : abap.char( 225 );
      @UI.hidden             : true
      messagetypestdchargeout    : abap.char( 1 );
      @UI.hidden             : true
      messagetyperecalculation     : abap.char( 1 );
      @UI.hidden             : true
      messagetypeforecast    : abap.char( 1 );
      @UI.selectionField     : [{ position: 100 }]
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_CHAINID_F4', element: 'ChainId' } }]
      chain_id               : /esrcc/chain_id;
      @UI.hidden             : true
      chain_sequence         : /esrcc/chain_sequence;
      @UI.hidden             : true
      logid          : sysuuid_c32;
      @UI.hidden             : true  
      logapp                 : /esrcc/application_type_de;
      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTDATASET', element: 'StdChargeoutfplv' } }]
      @UI.textArrangement    : #TEXT_ONLY
      @UI.hidden             : true
      StdChargeoutfplv       : /esrcc/costdataset_de;
//      @Consumption.valueHelpDefinition: [{ entity: { name: '/ESRCC/I_COSTDATASET', element: 'Recalculationfplv' } }]
      @UI.textArrangement    : #TEXT_ONLY
      @UI.hidden             : true
      Recalculationfplv      : /esrcc/costdataset_de;
      
      @UI.textArrangement    : #TEXT_ONLY
      @UI.hidden             : true
      Forecastfplv           : /esrcc/costdataset_de;
}
