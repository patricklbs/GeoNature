import { Component, NgModule, OnInit, OnDestroy, Inject } from '@angular/core';
import { NavService } from './services/nav.service';
import {TranslateService} from '@ngx-translate/core';
import {Router, ActivatedRoute} from '@angular/router';
import { Subscription } from 'rxjs/Subscription';
import * as firebase from 'firebase';
import { AuthService } from './components/auth/auth.service';
import {AppConfigs} from '../conf/app.configs';
import 'rxjs/Rx';


@Component({
  selector: 'pnx-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
  providers: [{ provide: AppConfigs, useValue: AppConfigs }]
})

export class AppComponent implements OnInit, OnDestroy {
  public appName: string;
  private subscription: Subscription;

  // tslint:disable-next-line:max-line-length
  constructor(private _navService: NavService, private translate: TranslateService,
              public authService: AuthService,
              private activatedRoute: ActivatedRoute,) {
      _navService.gettingAppName.subscribe(ms => {
        this.appName = ms;
    });

    translate.addLangs(['en', 'fr', 'cn']);
    translate.setDefaultLang(AppConfigs.defaultLanguage);

    // Get Lang of browser but if chose lang default in CONF we can not use this functionality
    // const browserLang = translate.getBrowserLang();
    // translate.use(browserLang.match(/en|fr|cn/) ? browserLang : 'en');
  }

  changeLanguage(lang) {
        this.translate.use(lang);
  }

  ngOnInit() {
    // subscribe to router event
    this.subscription = this.activatedRoute.queryParams.subscribe(
      (param: any) => {
        const locale = param['locale'];
        if (locale !== undefined) {
            this.translate.use(locale);
        }
      });
    // init firebase
    firebase.initializeApp({
      apiKey: 'AIzaSyBHvJhaMQdEFI0kM6LNagcFTQQWiDFCsOo',
      authDomain: 'geonature-a568d.firebaseapp.com',
    });
  }

  ngOnDestroy() {
    // prevent memory leak by unsubscribing
    this.subscription.unsubscribe();
  }

}