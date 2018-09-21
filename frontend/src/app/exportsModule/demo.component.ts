import { Component, OnInit } from '@angular/core';
import { FormControl } from '@angular/forms';
import { AppConfig } from '../../conf/app.config';

@Component({
  selector: 'pnx-demo-component',
  templateUrl: 'demo.component.html',
})
export class DemoComponent implements OnInit {
  public nomenclature_method_obs = new FormControl()
  public dataSetControl = new FormControl();
  public taxonControl = new FormControl();
  public viewList: Array<any>;
  constructor() {}

  ngOnInit() {

  }

  exportCsv(idView, idDataSet) {
    if (idDataSet) {
      document.location.href = `${
        AppConfig.API_ENDPOINT
      }/occtax/export/sinp?id_dataset=${idDataSet}`;
    } else {
      document.location.href = `${AppConfig.API_ENDPOINT}/occtax/export/sinp`;
    }
  }
}
