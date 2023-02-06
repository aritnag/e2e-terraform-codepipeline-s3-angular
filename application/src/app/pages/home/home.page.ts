import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  templateUrl: './home.page.html',
  styleUrls: ['./home.scss']
})
export class HomePage {

    constructor(private router: Router) { }

    navigateToUploadPage() {
      
        this.router.navigateByUrl("/upload")
    
      }
}
