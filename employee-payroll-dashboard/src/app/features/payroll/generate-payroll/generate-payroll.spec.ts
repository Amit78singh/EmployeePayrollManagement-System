import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GeneratePayroll } from './generate-payroll';

describe('GeneratePayroll', () => {
  let component: GeneratePayroll;
  let fixture: ComponentFixture<GeneratePayroll>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GeneratePayroll]
    })
    .compileComponents();

    fixture = TestBed.createComponent(GeneratePayroll);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
