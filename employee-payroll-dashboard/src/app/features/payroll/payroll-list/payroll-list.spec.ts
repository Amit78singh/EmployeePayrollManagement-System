import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PayrollList } from './payroll-list';

describe('PayrollList', () => {
  let component: PayrollList;
  let fixture: ComponentFixture<PayrollList>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PayrollList]
    })
    .compileComponents();

    fixture = TestBed.createComponent(PayrollList);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
