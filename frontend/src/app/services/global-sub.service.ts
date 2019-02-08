import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable()
export class GlobalSubService {
  // observable to set the current module
  public currentModuleSubject = new BehaviorSubject<any>(undefined);
  public currentModuleSub = this.currentModuleSubject.asObservable();
  // observable to set the current confif module
  public moduleConfigSubject = new BehaviorSubject<{ module_code: string; url: string }>(undefined);
  public moduleConfigSub = this.moduleConfigSubject.asObservable();
  constructor() {}
}
