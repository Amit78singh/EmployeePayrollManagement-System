import { ComponentFixture, TestBed } from '@angular/core/testing';

import { LoginLog } from './login-log';

describe('LoginLog', () => {
  let component: LoginLog;
  let fixture: ComponentFixture<LoginLog>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [LoginLog]
    })
    .compileComponents();

    fixture = TestBed.createComponent(LoginLog);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
