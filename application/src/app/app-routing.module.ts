import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import {HomePage} from './pages/home/home.page';
import {UploadS3Object} from './pages/s3upload/upload.page';
import {ObjectUploaded} from './pages/s3upload/objectuploaded.page';

const routes: Routes = [
  {path: '', component: HomePage},
  {path: 'upload', component: UploadS3Object},
  {path: 'objectuploaded', component: ObjectUploaded},
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
