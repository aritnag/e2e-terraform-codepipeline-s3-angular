import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import {HomePage} from './pages/home/home.page';
import {UploadS3Object} from './pages/s3upload/upload.page';
import {UploadFileService} from './pages/s3upload/upload.service';

@NgModule({
  declarations: [
    AppComponent,
    HomePage,
    UploadS3Object
  ],
  imports: [
    BrowserModule,
    AppRoutingModule
  ],
  providers: [UploadFileService],
  bootstrap: [AppComponent]
})
export class AppModule { }
